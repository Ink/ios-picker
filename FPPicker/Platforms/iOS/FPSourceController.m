//
//  ServiceController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPSourceController.h"
#import "FPThumbCell.h"
#import "UIImageView+AFNetworking.h"
#import "FPSaveSourceController.h"

@interface FPSourceController ()

@property int padding;
@property int numPerRow;
@property int thumbSize;
@property NSMutableSet *selectedObjects;
//Map from object id to thumbnail
@property NSMutableDictionary *selectedObjectThumbnails;

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *selectionOverlayImage;

/*!
   Operation queue for content preload requests.
   This operation queue (unlike FPAPIClient -operationQueue)
   supports unlimited simultaneous operations.
 */
@property (nonatomic, strong) NSOperationQueue *contentPreloadOperationQueue;

/*!
   Operation queue for content load requests.
   This operation queue is limited to 1 simultaneous operation.
 */
@property (nonatomic, strong) NSOperationQueue *contentLoadOperationQueue;

@end


@implementation FPSourceController

static const NSInteger CELL_FIRST_TAG = 1000;
static const CGFloat ROW_HEIGHT = 44.0;

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        NSUInteger selectedObjectsCapacity = self.maxFiles == 0 ? 10 : self.maxFiles;

        self.selectedObjects = [NSMutableSet setWithCapacity:selectedObjectsCapacity];
        self.selectedObjectThumbnails = [NSMutableDictionary dictionaryWithCapacity:selectedObjectsCapacity];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add "Pull to Refresh" control

    self.refreshControl = [UIRefreshControl new];

    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];

    // Make sure that we have a service

    if (!self.source)
    {
        return;
    }

    if (!self.path)
    {
        self.path = [NSString stringWithFormat:@"%@/", self.source.rootPath];
    }

    if (![self.source.identifier isEqualToString:FPSourceImagesearch])
    {
        // For Image Search, loading root is useless

        [self fpLoadContents:self.path
                 cachePolicy:NSURLRequestReloadRevalidatingCacheData];
    }

    [self setTitle:self.source.name];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    if (self.selectMultiple && ![self.viewType isEqualToString:@"thumbnails"])
    {
        self.tableView.allowsSelection = YES;
        self.tableView.allowsMultipleSelection = YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.contents = nil;
    self.path = nil;
    self.source = nil;
    self.fpdelegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupLayoutConstants];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.contentPreloadOperationQueue cancelAllOperations];
    [self.contentLoadOperationQueue cancelAllOperations];
    [self resetTableViewSelectionAndEnableUserInteraction];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //remove the pull down login label if applicable.
    UIView *v = [self.view viewWithTag:-1];

    if (v)
    {
        [v removeFromSuperview];
    }

    v = [self.view viewWithTag:-2];

    if (v)
    {
        [v removeFromSuperview];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self setupLayoutConstants];
    [self.tableView reloadData];
}

#pragma mark - Accessors

- (NSOperationQueue *)contentPreloadOperationQueue
{
    if (!_contentPreloadOperationQueue)
    {
        _contentPreloadOperationQueue = [NSOperationQueue new];
    }

    return _contentPreloadOperationQueue;
}

- (NSOperationQueue *)contentLoadOperationQueue
{
    if (!_contentLoadOperationQueue)
    {
        _contentLoadOperationQueue = [NSOperationQueue new];
        _contentLoadOperationQueue.maxConcurrentOperationCount = 1;
    }

    return _contentLoadOperationQueue;
}

- (UIImage *)placeholderImage
{
    if (!_placeholderImage)
    {
        NSString *placeHolderImageFilePath = [[FPUtils frameworkBundle] pathForResource:@"placeholder"
                                                                                 ofType:@"png"];

        _placeholderImage = [[UIImage imageWithContentsOfFile:placeHolderImageFilePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }

    return _placeholderImage;
}

- (UIImage *)selectionOverlayImage
{
    if (!_selectionOverlayImage)
    {
        NSString *selectOverlayFilePath = [[FPUtils frameworkBundle] pathForResource:@"SelectOverlayiOS7"
                                                                              ofType:@"png"];

        _selectionOverlayImage = [UIImage imageWithContentsOfFile:selectOverlayFilePath];
    }

    return _selectionOverlayImage;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.nextPage)
    {
        return 2;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([self.viewType isEqualToString:@"thumbnails"])
        {
            NSLog(@"Numofrows: %d %lu",
                  (int)ceilf(1.0f * self.contents.count / self.numPerRow),
                  (unsigned long)self.contents.count);

            return (int)ceilf(1.0f * self.contents.count / self.numPerRow);
        }
        else
        {
            return self.contents.count;
        }
    }
    else if (section == 1)
    {
        return 1;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.viewType isEqualToString:@"thumbnails"])
    {
        return self.thumbSize + self.padding;
    }

    return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)   // If it is the load more section
    {
        [self fpLoadNextPage]; // Load More Stuff from Internet
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = fpCellIdentifier;
    FPThumbCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell)
    {
        cell = [[FPThumbCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier :cellIdentifier];

        UIView *bgColorView = [UIView new];
        bgColorView.backgroundColor = [FPTableViewCell appearance].selectedBackgroundColor;
        cell.selectedBackgroundView = bgColorView;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.text = @"";
        cell.imageView.alpha = 1.0;
        cell.imageView.image = nil;
        cell.userInteractionEnabled = YES;

        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
    }

    if (self.nextPage && indexPath.section == 1)
    {
        return [self setupLoadMoreCell:cell];
    }

    if ([self.viewType isEqualToString:@"thumbnails"])
    {
        return [self setupThumbnailCell:cell
                                atIndex:indexPath.row];
    }
    else
    {
        return [self setupListCell:cell
                           atIndex:indexPath.row];
    }
}

- (UITableViewCell *)setupLoadMoreCell:(UITableViewCell *)cell
{
    self.nextPageSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.nextPageSpinner.hidesWhenStopped = YES;

    CGFloat height = ROW_HEIGHT;

    if ([self.viewType isEqualToString:@"thumbnails"])
    {
        height = self.thumbSize + self.padding;
    }

    self.nextPageSpinner.frame = CGRectMake(floorf(floorf(height - 20) * 0.5),
                                            floorf((height - 20) * 0.5),
                                            20,
                                            20);

    [cell addSubview:self.nextPageSpinner];
    [self.nextPageSpinner startAnimating];


    cell.textLabel.text = @"Loading more";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.userInteractionEnabled = NO;

    return cell;
}

- (UITableViewCell *)setupThumbnailCell:(UITableViewCell *)cell atIndex:(NSInteger)itemIndex
{
    NSLog(@"Thumbnail");

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(singleTappedWithGesture:)];

    [cell.contentView addGestureRecognizer:tap];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    CGRect rect = CGRectMake(self.padding,
                             self.padding,
                             self.thumbSize,
                             self.thumbSize);

    for (int i = 0; i < self.numPerRow; i++)
    {
        NSInteger index = self.numPerRow * itemIndex + i;

        NSLog(@"index: %ld", (long)index);

        if (index >= self.contents.count)
        {
            return cell;
        }

        NSMutableDictionary *obj = self.contents[index];
        NSURL *imageURL = [NSURL URLWithString:obj[@"thumbnail"]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];

        imageView.tag = CELL_FIRST_TAG + index;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;

        if (YES == [obj[@"disabled"] boolValue])
        {
            imageView.alpha = 0.5;
        }
        else
        {
            imageView.alpha = 1.0;
        }

        [imageView setImageWithURL:imageURL
                  placeholderImage:self.placeholderImage];

        BOOL thumbExists = [obj[@"thumb_exists"] boolValue];

        if (!thumbExists)
        {
            UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          self.thumbSize - 30,
                                                                          self.thumbSize,
                                                                          30)];

            subLabel.textColor = [UIColor blackColor];
            subLabel.font = [UIFont systemFontOfSize:16];
            subLabel.backgroundColor = [UIColor clearColor];
            subLabel.text = obj[@"filename"];
            subLabel.textAlignment = NSTextAlignmentCenter;

            [imageView addSubview:subLabel];

            imageView.contentMode = UIViewContentModeCenter;
            imageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
        }
        else
        {
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }


        if (self.selectMultiple)
        {
            // Add overlay

            UIImageView *overlay = [[UIImageView alloc] initWithImage:self.selectionOverlayImage];

            overlay.frame = imageView.bounds;

            // If this object is selected, leave the overlay on.
            overlay.hidden = ![self.selectedObjects containsObject:obj];

            overlay.opaque = NO;

            [imageView addSubview:overlay];
        }

        [cell.contentView addSubview:imageView];

        rect.origin.x += self.thumbSize + self.padding;
    }

    return cell;
}

- (UITableViewCell *)setupListCell:(UITableViewCell *)cell atIndex:(NSInteger)itemIndex
{
    if (itemIndex >= self.contents.count)
    {
        return cell;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    NSMutableDictionary *obj = self.contents[itemIndex];

    cell.tag = itemIndex;
    cell.textLabel.text = obj[@"filename"];

    if (YES == [obj[@"is_dir"] boolValue])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        [self fpPreloadContents:obj[@"link_path"]
                        forCell:cell.tag];
    }

    BOOL thumbExists = [obj[@"thumb_exists"] boolValue];
    BOOL isDir = [obj[@"is_dir"] boolValue];

    if (thumbExists)
    {
        NSString *urlString = obj[@"thumbnail"];

        NSLog(@"Thumb with URL: %@", urlString);

        if (isDir)
        {
            NSString *iconFilePath = [[FPUtils frameworkBundle] pathForResource:@"glyphicons_144_folder_open"
                                                                         ofType:@"png"];

            cell.imageView.image = [[UIImage imageWithContentsOfFile:iconFilePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.contentMode = UIViewContentModeCenter;
        }
        else
        {
            NSString *placeHolderImageFilePath = [[FPUtils frameworkBundle] pathForResource:@"placeholder"
                                                                                     ofType:@"png"];

            UIImage *placeHolderImage = [[UIImage imageWithContentsOfFile:placeHolderImageFilePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

            [cell.imageView setImageWithURL:[NSURL URLWithString:urlString]
                           placeholderImage:placeHolderImage];

            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
    else
    {
        if (isDir)
        {
            NSString *iconFilePath = [[FPUtils frameworkBundle] pathForResource:@"glyphicons_144_folder_open"
                                                                         ofType:@"png"];

            cell.imageView.image = [[UIImage imageWithContentsOfFile:iconFilePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else
        {
            NSString *iconFilePath = [[FPUtils frameworkBundle] pathForResource:@"glyphicons_036_file"
                                                                         ofType:@"png"];

            cell.imageView.image = [[UIImage imageWithContentsOfFile:iconFilePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }

        cell.imageView.contentMode = UIViewContentModeCenter;
    }

    if (YES == [obj[@"disabled"] boolValue])
    {
        UIColor *existingCellColor = cell.textLabel.textColor;
        UIColor *newCellColor = [existingCellColor colorWithAlphaComponent:0.5];

        cell.textLabel.textColor = newCellColor;
        cell.imageView.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)passedTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)passedTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *obj = self.contents[indexPath.row];
    BOOL isDir = [obj[@"is_dir"] boolValue];
    UIImage *thumbnail = [tableView cellForRowAtIndexPath:indexPath].imageView.image;
    BOOL thumbExists = [obj[@"thumb_exists"] boolValue];

    if (thumbExists)
    {
        [self objectSelectedAtIndex:indexPath.row
                            forView:tableView
                      withThumbnail:thumbnail];
    }
    else
    {
        [self objectSelectedAtIndex:indexPath.row
                            forView:tableView];
    }

    // Clear selection if object is a directory

    if (isDir)
    {
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *obj = [self.contents objectAtIndex:indexPath.row];

    if ([self.selectedObjects containsObject:obj])
    {
        [self.selectedObjects removeObject:obj];
    }
    else
    {
        [self.selectedObjects addObject:obj];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUploadButton:self.selectedObjects.count];
    });
}

#pragma mark - Actions

- (IBAction)uploadButtonTapped:(id)sender
{
    [super uploadButtonTapped:sender];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                                              animated:YES];

    hud.mode = MBProgressHUDModeDeterminate;

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.selectedObjects.count];
    NSInteger totalCount = self.selectedObjects.count;
    NSInteger __block amtProcessed = 0;

    if (totalCount == 1)
    {
        hud.labelText = @"Downloading 1 file";
    }
    else
    {
        hud.labelText = [NSString stringWithFormat:@"Downloading 1 of %ld files", (long)totalCount];
    }

    FPProgressTracker *progressTracker = [[FPProgressTracker alloc] initWithObjectCount:self.selectedObjects.count];

    for (NSDictionary *obj in self.selectedObjects)
    {
        // We push all the uploads onto background threads. Now we have to be careful
        // as we're working in multi-threaded environment.

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSInteger index = [self.contents indexOfObject:obj];
            UIImage *thumbnail = self.selectedObjectThumbnails[@(index)];

            void (^markProgress)() = ^void () {
                amtProcessed++;

                if (amtProcessed >= totalCount)
                {
                    hud.labelText = @"Finished uploading";

                    [self finishMultipleUpload:results];
                }
                else
                {
                    hud.labelText = [NSString stringWithFormat:@"Downloading %lu of %ld files", (long)amtProcessed + 1, (long)totalCount];
                }

                hud.progress = [progressTracker setProgress:1.f
                                                     forKey:obj];
            };

            FPFetchObjectSuccessBlock successBlock = ^(FPMediaInfo *mediaInfo) {
                [results addObject:mediaInfo];
                markProgress();
            };

            FPFetchObjectFailureBlock failureBlock = ^(NSError *error) {
                NSForceLog(@"FAIL %@", error);

                if (error.code == kCFURLErrorNotConnectedToInternet ||
                    error.code == kCFURLErrorRedirectToNonExistentLocation ||
                    error.code == kCFURLErrorUnsupportedURL)
                {
                    [self fpLoadResponseFailureWithError:error
                                                 handler: ^{
                        [self resetTableViewSelectionAndEnableUserInteraction];
                    }];
                }
                else
                {
                    markProgress();
                }
            };

            FPFetchObjectProgressBlock progressBlock = ^(float progress) {
                hud.progress = [progressTracker setProgress:progress
                                                     forKey:obj];
            };

            [self fetchObject:obj
                withThumbnail:thumbnail
                      success:successBlock
                      failure:failureBlock
                     progress:progressBlock];
        });
    }
}

- (IBAction)singleTappedWithGesture:(UIGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationOfTouch:sender.view.tag
                                        inView:sender.view];

    int cellWidth = self.thumbSize + self.padding;
    int rowIndex = (int)MIN(floor(tapPoint.x / cellWidth), self.numPerRow - 1);

    // Do nothing if there isn't a corresponding image view.

    if (rowIndex >= sender.view.subviews.count)
    {
        return;
    }

    UIImageView *selectedView = sender.view.subviews[rowIndex];

    // Do nothing if image view has an invalid tag

    if (selectedView.tag <= 0)
    {
        return;
    }

    NSInteger index = selectedView.tag - CELL_FIRST_TAG;
    NSMutableDictionary *obj = self.contents[index];
    UIImage *thumbnail;

    BOOL thumbExists = [obj[@"thumb_exists"] boolValue];

    if (thumbExists)
    {
        thumbnail = selectedView.image;

        [self objectSelectedAtIndex:index
                            forView:sender.view
                      withThumbnail:thumbnail];
    }
    else
    {
        [self objectSelectedAtIndex:index
                            forView:sender.view];
    }
}

#pragma mark - Private Methods

- (void)fpAuthResponse
{
    [self fpLoadContents:self.path
             cachePolicy:NSURLRequestReloadIgnoringCacheData];
}

/*
 *  The default wrapper for fpLoadContents.
 *  I presume that cached data is fine unless you specify specifically.
 */
- (void)fpLoadContents:(NSString *)loadpath
{
    [self fpLoadContents:loadpath
             cachePolicy:NSURLRequestReturnCacheDataElseLoad];
}

- (void)fpLoadContents:(NSString *)loadpath
           cachePolicy:(NSURLRequestCachePolicy)policy
{
    [self clearSelection];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                                              animated:YES];

    hud.labelText = @"Loading contents";

    NSURLRequest *request = [FPLibrary requestForLoadPath:loadpath
                                               withFormat:@"info"
                                              queryString:nil
                                             andMimetypes:self.source.mimetypes
                                              cachePolicy:policy];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        [self fpLoadResponseSuccessAtPath:loadpath
                               withResult:responseObject];

        [self.refreshControl endRefreshing];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (error.code == kCFURLErrorUserCancelledAuthentication)
        {
            [self fpLoadContents:loadpath
                     cachePolicy:NSURLRequestReloadIgnoringCacheData];
        }
        else
        {
            [self fpLoadResponseFailureWithError:error
                                         handler: ^{
                [self resetTableViewSelectionAndEnableUserInteraction];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }

        [self.refreshControl endRefreshing];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.contentLoadOperationQueue cancelAllOperations];
    [self.contentLoadOperationQueue addOperation:operation];
}

- (void)fpLoadResponseSuccessAtPath:(NSString *)loadpath
                         withResult:(id)JSON
{
    NSLog(@"Loading Contents: %@", JSON);

    self.contents = JSON[@"contents"];
    self.viewType = JSON[@"view"];

    id next = JSON[@"next"];

    if (next && next != [NSNull null])
    {
        if ([next respondsToSelector:@selector(stringValue)])
        {
            self.nextPage = [next stringValue];
        }
        else
        {
            self.nextPage = next;
        }
    }
    else
    {
        self.nextPage = nil;
    }

    if (![self.viewType isEqualToString:@"thumbnails"])
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    [self setTitle:[JSON valueForKey:@"filename"]];

    if (JSON[@"auth"])
    {
        [self launchAuthView];
    }
    else
    {
        if ([loadpath isEqualToString:[NSString stringWithFormat:@"%@/", self.source.rootPath]])
        {
            //logout only on root level
            UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(logout:)];

            self.navigationItem.rightBarButtonItem = anotherButton;
        }

        if ([JSON[@"contents"] count] == 0 &&
            (self.source.identifier != FPSourceImagesearch))
        {
            [self setupEmptyView];
        }
    }

    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];

    [self.tableView reloadData];
    [self afterReload];
}

- (void)fpLoadResponseFailureWithError:(NSError *)error
                               handler:(void (^ __nullable)(void))handler
{
    if (error.code == kCFURLErrorCancelled)
    {
        return;
    }

    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];

    if ([FPUtils currentAppIsAppExtension])
    {
        NSForceLog(@"ERROR: %@", error);

        if (handler)
        {
            handler();
        }
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Internet Connection"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler: ^(UIAlertAction * action)
        {
            if (handler)
            {
                handler();
            }
        }];

        [alert addAction:ok];

        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

- (void)fpPreloadContents:(NSString *)loadpath
{
    [self fpPreloadContents:loadpath
                    forCell:-1];
}

- (void)fpPreloadContents:(NSString *)loadpath
              cachePolicy:(NSURLRequestCachePolicy)policy
{
    NSLog(@"trying to refresh a path");
    [self fpPreloadContents:loadpath
                    forCell:-1
                cachePolicy:policy];
}

- (void)fpPreloadContents:(NSString *)loadpath
                  forCell:(NSInteger)cellIndex
{
    [self fpPreloadContents:loadpath
                    forCell:cellIndex
                cachePolicy:NSURLRequestReturnCacheDataElseLoad];
}

- (void)fpPreloadContents:(NSString *)loadpath
                  forCell:(NSInteger)cellIndex
              cachePolicy:(NSURLRequestCachePolicy)policy
{
    NSURLRequest *request = [FPLibrary requestForLoadPath:loadpath
                                               withFormat:@"info"
                                              queryString:nil
                                             andMimetypes:self.source.mimetypes
                                              cachePolicy:policy];

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:nil
                                                                    failure:nil];

    [self.contentPreloadOperationQueue addOperation:operation];
}

- (void)fpLoadNextPage
{
    NSLog(@"Next page: %@", self.nextPage);

    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.path];

    NSArray *queryItems = @[
        [NSURLQueryItem queryItemWithName:@"start" value:[FPUtils urlEncodeString:self.nextPage]]
    ];

    if (urlComponents.queryItems)
    {
        urlComponents.queryItems = [urlComponents.queryItems arrayByAddingObjectsFromArray:queryItems];
    }
    else
    {
        urlComponents.queryItems = queryItems;
    }

    NSURLRequest *request = [FPLibrary requestForLoadPath:urlComponents.path
                                               withFormat:@"info"
                                              queryString:urlComponents.query
                                             andMimetypes:self.source.mimetypes
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.contents];

        [tempArray addObjectsFromArray:responseObject[@"contents"]];
        self.contents = tempArray;

        id next = responseObject[@"next"];

        if (next && next != [NSNull null])
        {
            if ([next respondsToSelector:@selector(stringValue)])
            {
                self.nextPage = [next stringValue];
            }
            else
            {
                self.nextPage = next;
            }
        }
        else
        {
            self.nextPage = nil;
        }

        [self.tableView reloadData];
        [self.nextPageSpinner stopAnimating];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        NSForceLog(@"ERROR: %@", error);

        self.nextPage = nil;

        [self.tableView reloadData];
        [self.nextPageSpinner stopAnimating];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.contentPreloadOperationQueue addOperation:operation];
}

- (void)clearSelection
{
    for (id index in self.selectedObjectThumbnails)
    {
        UIView *view = [self.view viewWithTag:CELL_FIRST_TAG + [index intValue]];

        [self toggleSelectionOnThumbnailView:view];
    }

    [self.selectedObjects removeAllObjects];
    [self.selectedObjectThumbnails removeAllObjects];

    // Hide upload button too

    [self updateUploadButton:0];
}

- (void)objectSelectedAtIndex:(NSInteger)index
                      forView:(UIView *)view
{
    [self objectSelectedAtIndex:index
                        forView:view
                  withThumbnail:nil];
}

- (void)objectSelectedAtIndex:(NSInteger)index
                      forView:(UIView *)view
                withThumbnail:(UIImage *)thumbnail
{
    NSDictionary *obj = self.contents[index];

    BOOL isDisabled = [obj[@"disabled"] boolValue];
    BOOL isDir = [obj[@"is_dir"] boolValue];

    if (isDisabled)
    {
        return;
    }
    else if (isDir)
    {
        [self pushDirectoryControllerForPath:obj[@"link_path"]];

        return;
    }
    else
    {
        [self fileSelectedAtIndex:index forView:view withThumbnail:thumbnail];
    }
}

- (void)pushDirectoryControllerForPath:(NSString*)path
{
    FPSourceController *subController = [FPSourceController new];

    subController.path = path;
    subController.source = self.source;
    subController.fpdelegate = self.fpdelegate;
    subController.selectMultiple = self.selectMultiple;
    subController.maxFiles = self.maxFiles;

    [self.navigationController pushViewController:subController
                                         animated:YES];
}

- (void)fileSelectedAtIndex:(NSInteger)index
                    forView:(UIView*)view
              withThumbnail:(UIImage *)thumbnail
{
    NSDictionary *obj = self.contents[index];

    if (self.selectMultiple)
    {
        UIView *childView = [view viewWithTag:CELL_FIRST_TAG + index];

        if ([self.viewType isEqualToString:@"thumbnails"])
        {
            [self toggleSelectionOnThumbnailView:childView];
        }

        // Table selection takes care of list views, so no need for an else

        if ([self.selectedObjects containsObject:obj])
        {
            [self.selectedObjects removeObject:obj];
            [self.selectedObjectThumbnails removeObjectForKey:@(index)];
        }
        else
        {
            [self.selectedObjects addObject:obj];

            if (thumbnail)
            {
                self.selectedObjectThumbnails[@(index)] = thumbnail;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUploadButton:self.selectedObjects.count];
        });
    }
    else
    {
        __block MBProgressHUD *hud;

        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                                       animated:YES];

            hud.mode = MBProgressHUDModeDeterminate;
            hud.labelText = @"Downloading file";
        });

        FPFetchObjectSuccessBlock successBlock = ^(FPMediaInfo *mediaInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                         animated:YES];

                [self.fpdelegate sourceController:self
                    didFinishPickingMediaWithInfo:mediaInfo];
            });
        };

        FPFetchObjectFailureBlock failureBlock = ^(NSError *error) {
            NSForceLog(@"ERROR: %@", error);

            [self fpLoadResponseFailureWithError:error
                                         handler: ^{
                [self resetTableViewSelectionAndEnableUserInteraction];
            }];

            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                         animated:YES];

                [self.fpdelegate sourceControllerDidCancel:self];
            });
        };

        FPFetchObjectProgressBlock progressBlock = ^(float progress) {
            hud.progress = progress;
        };

        [self fetchObject:obj
            withThumbnail:thumbnail
                  success:successBlock
                  failure:failureBlock
                 progress:progressBlock];
    }
}

- (void)resetTableViewSelectionAndEnableUserInteraction
{
    self.tableView.userInteractionEnabled = YES;

    [self.selectedObjects removeAllObjects];

    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows)
    {
        [self.tableView deselectRowAtIndexPath:indexPath
                                      animated:YES];
    }

    [self updateUploadButton:0];
}

- (void)toggleSelectionOnThumbnailView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *overlay = view.subviews[0];

        overlay.hidden = !overlay.hidden;
    });
}

- (void)finishMultipleUpload:(NSArray *)results
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                 animated:YES];

        [self.fpdelegate sourceController:nil
         didFinishPickingMultipleMediaWithResults:results];
    });
}

- (void)fetchObject:(NSDictionary *)obj
      withThumbnail:(UIImage *)thumbnail
            success:(FPFetchObjectSuccessBlock)success
            failure:(FPFetchObjectFailureBlock)failure
           progress:(FPFetchObjectProgressBlock)progress
{
    DLog(@"Selected Contents: %@", obj);

    FPMediaInfo *mediaInfo = [FPMediaInfo new];

    mediaInfo.filename = obj[@"filename"];

    NSString *mimeType = obj[@"mimetype"];
    if (mimeType && ![mimeType isKindOfClass:[NSString class]]) {
        // Fix #117: Safely cast the "mimetype" property to NSString, since it may be [NSNull null].
        // UTIForMimetype will return a value like "dyn.agq8u" when given an empty string.
        mimeType = @"";
    }
    mediaInfo.mediaType = [FPUtils UTIForMimetype:mimeType];
    mediaInfo.filesize = obj[@"bytes"];
    mediaInfo.source = self.source;

    if (thumbnail)
    {
        mediaInfo.thumbnailImage = thumbnail;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fpdelegate sourceController:self
                     didPickMediaWithInfo:mediaInfo];

        self.view.userInteractionEnabled = NO;
    });

    [FPLibrary requestObjectMediaInfo:obj
                           withSource:self.source
                  usingOperationQueue:self.contentPreloadOperationQueue
                              success:success
                              failure:failure
                             progress:progress];
}

- (void)refresh
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];

    [self fpLoadContents:self.path
             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
}

- (void)logout:(NSObject *)button
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/unauth", fpBASE_URL, self.source.identifier];

    NSLog(@"Logout: %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:240];

    [MBProgressHUD showHUDAddedTo:self.navigationController.view
                         animated:YES];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSLog(@"Logout result: %@", responseObject);

        [self fpPreloadContents:self.path
                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];


        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        for (NSHTTPCookie __unused *cookie in cookieStorage.cookies)
        {
            NSLog(@"%@", cookie.domain);
        }

        for (NSString *urlString in self.source.externalDomains)
        {
            NSArray *siteCookies;
            siteCookies = [cookieStorage cookiesForURL:[NSURL URLWithString:urlString]];

            for (NSHTTPCookie *cookie in siteCookies)
            {
                [cookieStorage deleteCookie:cookie];
            }
        }

        for (NSHTTPCookie __unused *cookie in cookieStorage.cookies)
        {
            NSLog(@"- %@", cookie.domain);
        }


        [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                 animated:YES];

        [self.navigationController popViewControllerAnimated:YES];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                 animated:YES];

        if (![FPUtils currentAppIsAppExtension])
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout Failure"
                                                                           message:@"Hmm. We weren't able to logout."
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction * action)
            {
                // NO-OP
            }];

            [alert addAction:ok];

            [self presentViewController:alert
                               animated:YES
                             completion:nil];
        }
        else
        {
            NSForceLog(@"ERROR: %@", error);
        }
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.contentPreloadOperationQueue addOperation:operation];
}

- (CGRect)getViewBounds
{
    CGRect bounds = self.view.bounds;
    UIView *parent = self.view.superview;

    if (parent)
    {
        bounds = parent.bounds;
    }

    return bounds;
}

- (void)afterReload
{
    // No-op
    // Will be overriden by subclasses
}

- (void)launchAuthView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fpAuthResponse)
                                                 name:FPPickerDidAuthenticateAgainstSourceNotification
                                               object:nil];

    FPAuthController *authView = [[FPAuthController alloc] initWithSource:self.source];

    [self.navigationController pushViewController:authView
                                         animated:NO];
}

- (void)setupEmptyView
{
    CGRect bounds = [self getViewBounds];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetMidY(bounds) - 60,
                                                                      CGRectGetWidth(bounds),
                                                                      30)];
    headingLabel.tag = -1;
    headingLabel.textColor = [UIColor grayColor];
    headingLabel.font = [UIFont systemFontOfSize:25];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    headingLabel.text = @"No files here";

    [self.view addSubview:headingLabel];

    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  CGRectGetMidY(bounds) - 30,
                                                                  CGRectGetWidth(bounds),
                                                                  30)];
    subLabel.tag = -2;
    subLabel.textColor = [UIColor grayColor];
    subLabel.textAlignment = NSTextAlignmentCenter;
    subLabel.text = @"Pull down to refresh";

    [self.view addSubview:subLabel];
}

- (void)setupLayoutConstants
{
    CGSize screenSize = [self getViewBounds].size;

    self.thumbSize = fpRemoteThumbSize;
    self.numPerRow = (int)screenSize.width / self.thumbSize;
    self.padding = (int)((screenSize.width - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));

    if (self.padding < 4)
    {
        self.numPerRow -= 1;
        self.padding = (int)((screenSize.width - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));
    }
}

@end
