//
//  ServiceController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPSourceController.h"
#import "FPSaveController.h"
#import "FPAuthController.h"
#import "FPInternalHeaders.h"
#import "FPUtils.h"
#import "FPThumbCell.h"
#import "FPProgressTracker.h"
#import "UIImageView+AFNetworking.h"

typedef void (^FPFetchObjectSuccessBlock)(NSDictionary *data);
typedef void (^FPFetchObjectFailureBlock)(NSError *error);
typedef void (^FPFetchObjectProgressBlock)(float progress);

@interface FPSourceController ()

@property int padding;
@property int numPerRow;
@property int thumbSize;
@property NSMutableSet *selectedObjects;
//Map from object id to thumbnail
@property NSMutableDictionary *selectedObjectThumbnails;

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *selectionOverlayImage;

@end

@implementation FPSourceController

static const NSInteger CELL_FIRST_TAG = 1000;
static const NSInteger ROW_HEIGHT = 44;
//static const CGFloat UPLOAD_BUTTON_CONTAINER_HEIGHT = 45.f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    if (self)
    {
        NSUInteger selectedObjectsCapacity = self.maxFiles == 0 ? 10 : self.maxFiles;

        self.selectedObjects = [NSMutableSet setWithCapacity:selectedObjectsCapacity];
        self.selectedObjectThumbnails = [NSMutableDictionary dictionaryWithCapacity:selectedObjectsCapacity];
    }

    return self;
}

- (void)backButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Make sure that we have a service

    if (!self.sourceType)
    {
        return;
    }

    if (!self.path)
    {
        self.path = [NSString stringWithFormat:@"%@/", self.sourceType.rootUrl];
    }

    if (![self.sourceType.identifier isEqualToString:FPSourceImagesearch])
    {
        //For Image Search, loading root is useless
        [self fpLoadContents:self.path];
    }

    [self setTitle:self.sourceType.name];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.precacheOperations = [NSMutableDictionary dictionary];

    if (self.selectMultiple && ![self.viewType isEqualToString:@"thumbnails"])
    {
        self.tableView.allowsSelection = YES;
        self.tableView.allowsMultipleSelection = YES;
    }

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonAction)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.contents = nil;
    self.path = nil;
    self.sourceType = nil;
    self.fpdelegate = nil;
    //TODO: get rid of precaching ops
    self.precacheOperations = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.contentSizeForViewInPopover = fpWindowSize;

    CGRect bounds = [self getViewBounds];
    self.thumbSize = fpRemoteThumbSize;
    self.numPerRow = (int)bounds.size.width / self.thumbSize;
    self.padding = (int)((bounds.size.width - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));

    if (self.padding < 4)
    {
        self.numPerRow -= 1;
        self.padding = (int)((bounds.size.width - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));
    }

    [super viewWillAppear:animated];
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

- (UIImage *)placeholderImage
{
    if (!_placeholderImage)
    {
        NSString *placeHolderImageFilePath = [[FPUtils frameworkBundle] pathForResource:@"placeholder"
                                                                                 ofType:@"png"];

        _placeholderImage = [UIImage imageWithContentsOfFile:placeHolderImageFilePath];
    }

    return _placeholderImage;
}

- (UIImage *)selectionOverlayImage
{
    if (!_selectionOverlayImage)
    {
        NSString *selectOverlayFilePath;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            selectOverlayFilePath = [[FPUtils frameworkBundle] pathForResource:@"SelectOverlayiOS7"
                                                                        ofType:@"png"];
        }
        else
        {
            selectOverlayFilePath = [[FPUtils frameworkBundle] pathForResource:@"SelectOverlay"
                                                                        ofType:@"png"];
        }

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
    FPThumbCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell)
    {
        cell = [[FPThumbCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
    }
    else
    {
        // You need to cancel the old precache request.

        NSString *precacheKey = [NSString stringWithFormat:@"precache_%ld", (long)indexPath.row];

        if (self.precacheOperations[precacheKey])
        {
            AFHTTPRequestOperation *operation = self.precacheOperations[precacheKey];

            [operation cancel];
        }

        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.imageView.alpha = 1.0;
        cell.imageView.image = nil;
        cell.textLabel.text = @"";
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

    NSInteger height = ROW_HEIGHT;

    if ([self.viewType isEqualToString:@"thumbnails"])
    {
        height = self.thumbSize + self.padding;
    }

    self.nextPageSpinner.frame = CGRectMake(floorf(floorf(height - 20) / 2),
                                            floorf((height - 20) / 2),
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
            imageView.contentMode = UIViewContentModeScaleAspectFill;
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

    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    NSMutableDictionary *obj = self.contents[itemIndex];

    cell.tag = itemIndex;
    cell.textLabel.text = obj[@"filename"];

    if (YES == [obj[@"is_dir"] boolValue])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor blackColor];

        [self fpPreloadContents:obj[@"link_path"]
                        forCell:cell.tag];
    }

    NSLog(@"Thumb exists%@", obj[@"thumb_exists"]);

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

            cell.imageView.image = [UIImage imageWithContentsOfFile:iconFilePath];
            cell.imageView.contentMode = UIViewContentModeCenter;
        }
        else
        {
            NSString *placeHolderImageFilePath = [[FPUtils frameworkBundle] pathForResource:@"placeholder"
                                                                                     ofType:@"png"];

            UIImage *placeHolderImage = [UIImage imageWithContentsOfFile:placeHolderImageFilePath];

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

            cell.imageView.image = [UIImage imageWithContentsOfFile:iconFilePath];
        }
        else
        {
            NSString *iconFilePath = [[FPUtils frameworkBundle] pathForResource:@"glyphicons_036_file"
                                                                         ofType:@"png"];

            cell.imageView.image = [UIImage imageWithContentsOfFile:iconFilePath];
        }

        cell.imageView.contentMode = UIViewContentModeCenter;
    }

    if (YES == [obj[@"disabled"] boolValue])
    {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.imageView.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    }

    if (isDir)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    UIImage *thumbnail = [self.tableView cellForRowAtIndexPath:indexPath].imageView.image;
    BOOL thumbExists = [obj[@"thumb_exists"] boolValue];

    if (thumbExists)
    {
        [self objectSelectedAtIndex:indexPath.row
                      withThumbnail:thumbnail];
    }
    else
    {
        [self objectSelectedAtIndex:indexPath.row];
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

    FPMBProgressHUD *hud = [FPMBProgressHUD showHUDAddedTo:self.view
                                                  animated:YES];

    hud.mode = FPMBProgressHUDModeDeterminate;

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.selectedObjects.count];

    // TODO: What should we do on failures? Right now we just press forward, but
    // You could imagine wanting to fail fast

    NSInteger __block totalCount = self.selectedObjects.count;

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

            FPFetchObjectSuccessBlock successBlock = ^(NSDictionary *data) {
                @synchronized(results)
                {
                    [results addObject:data];

                    // Check >= in case we miss (we shouldn't, but hey, better safe than sorry)

                    if (results.count >= totalCount)
                    {
                        hud.labelText = @"Finished uploading";

                        [self finishMultipleUpload:results];
                    }
                    else
                    {
                        hud.labelText = [NSString stringWithFormat:@"Downloading %lu of %ld files", (long)results.count + 1, (long)totalCount];
                    }
                }

                @synchronized(progressTracker)
                {
                    hud.progress = [progressTracker setProgress:1.f
                                                         forKey:obj];
                }
            };

            FPFetchObjectFailureBlock failureBlock = ^(NSError *error) {
                NSLog(@"FAIL %@", error);

                [FPMBProgressHUD hideAllHUDsForView:self.view
                                           animated:YES];

                if (error.code == kCFURLErrorRedirectToNonExistentLocation ||
                    error.code == kCFURLErrorUnsupportedURL)
                {
                    [self.navigationController popViewControllerAnimated:YES];

                    UIAlertView *message;

                    message = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                         message:@"You aren't connected to the internet so we can't get your files."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];

                    [message show];
                }

                [self.fpdelegate FPSourceControllerDidCancel:self];
            };

            FPFetchObjectProgressBlock progressBlock = ^(float progress) {
                @synchronized(progressTracker)
                {
                    hud.progress = [progressTracker setProgress:progress
                                                         forKey:obj];
                }
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

    int rowIndex = (int)MIN(floor(tapPoint.x / 105), self.numPerRow - 1);

    // Do nothing if there isn't a corresponding image view.

    if (rowIndex >= [sender.view.subviews count])
    {
        return;
    }

    UIImageView *selectedView = sender.view.subviews[rowIndex];
    NSInteger index = selectedView.tag - CELL_FIRST_TAG;

    NSMutableDictionary *obj = self.contents[index];
    UIImage *thumbnail;

    BOOL thumbExists = [obj[@"thumb_exists"] boolValue];

    if (thumbExists)
    {
        thumbnail = selectedView.image;

        [self objectSelectedAtIndex:index
                      withThumbnail:thumbnail];
    }
    else
    {
        [self objectSelectedAtIndex:index];
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

- (void)fpLoadContents:(NSString *)loadpath cachePolicy:(NSURLRequestCachePolicy)policy
{
    [self clearSelection];

    UIView *hudParentView = self.view.superview ? self.view.superview : self.view;

    FPMBProgressHUD *hud = [FPMBProgressHUD showHUDAddedTo:hudParentView
                                                  animated:YES];

    hud.labelText = @"Loading contents";

    NSURLRequest *request = [self requestForLoadPath:loadpath
                                          withFormat:@"info"
                                         cachePolicy:policy];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        [self fpLoadResponseSuccessAtPath:loadpath
                               withResult:responseObject];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        [self fpLoadResponseFailureAtPath:loadpath
                                withError:error];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    if ([self.sourceType.identifier isEqualToString:FPSourceImagesearch])
    {
        AFHTTPRequestOperation *oldOperation = self.precacheOperations[@"imagesearch_"];

        [oldOperation cancel];

        self.precacheOperations[@"imagesearch_"] = operation;
    }

    [[FPAPIClient sharedClient].operationQueue addOperation:operation];
}

- (void)fpLoadResponseSuccessAtPath:(NSString *)loadpath withResult:(id)JSON
{
    NSLog(@"Loading Contents: %@", JSON);

    self.contents = JSON[@"contents"];
    self.viewType = JSON[@"view"];

    NSString *next = JSON[@"next"];

    if (next && next != (NSString *)[NSNull null])
    {
        self.nextPage = next;
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
        if ([loadpath isEqualToString:[NSString stringWithFormat:@"%@/", self.sourceType.rootUrl]])
        {
            //logout only on root level
            UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(logout:)];

            self.navigationItem.rightBarButtonItem = anotherButton;
        }

        if ([JSON[@"contents"] count] == 0 &&
            (self.sourceType.identifier != FPSourceImagesearch))
        {
            NSLog(@"nothing");

            [self setupEmptyView];
        }
    }

    if (self.view.superview)
    {
        [FPMBProgressHUD hideAllHUDsForView:self.view.superview
                                   animated:YES];
    }

    [FPMBProgressHUD hideAllHUDsForView:self.view
                               animated:YES];

    [self.tableView reloadData];

    NSLog(@"after reload");

    if ([self.sourceType.identifier isEqualToString:FPSourceImagesearch])
    {
        //NSLog(@"%@", self.searchDisplayController);
        [self.searchDisplayController.searchResultsTableView reloadData];
    }


    [self afterReload];
}

- (void)fpLoadResponseFailureAtPath:(NSString *)loadpath
                          withError:(NSError *)error
{
    [FPMBProgressHUD hideAllHUDsForView:self.view
                               animated:YES];

    NSLog(@"Error: %@", error);

    //NSLog(@"Loading Contents: %@", JSON);

    if (error.code == kCFURLErrorRedirectToNonExistentLocation ||
        error.code == kCFURLErrorUnsupportedURL)
    {
        [self.navigationController popViewControllerAnimated:YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                          message:@"You aren't connected to the internet so we can't get your files."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];

        [message show];
    }

    if (error.code == kCFURLErrorUserCancelledAuthentication)
    {
        [self fpLoadContents:loadpath
                 cachePolicy:NSURLRequestReloadIgnoringCacheData];
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
    NSInteger nilInteger = -1;

    NSURLRequest *request = [self requestForLoadPath:loadpath
                                          withFormat:@"info"
                                         cachePolicy:policy];

    NSString *precacheKey = [NSString stringWithFormat:@"precache_%ld", (long)cellIndex];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        //NSLog(@"JSON: %@", JSON);
        if (cellIndex != nilInteger)
        {
            [self.precacheOperations removeObjectForKey:precacheKey];
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (cellIndex != nilInteger)
        {
            [self.precacheOperations removeObjectForKey:precacheKey];
        }
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [[FPAPIClient sharedClient].operationQueue addOperation:operation];

    if (cellIndex != nilInteger)
    {
        self.precacheOperations[precacheKey] = operation;
    }
}

- (void)fpLoadNextPage
{
    NSLog(@"Next page: %@", self.nextPage);

    NSString *nextPageParam = [NSString stringWithFormat:@"&start=%@", [FPUtils urlEncodeString:self.nextPage]];

    NSLog(@"nextpageparm: %@", nextPageParam);

    NSURLRequest *request = [self requestForLoadPath:self.path
                                          withFormat:@"info"
                                         byAppending:nextPageParam
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.contents];

        [tempArray addObjectsFromArray:responseObject[@"contents"]];
        self.contents = tempArray;

        NSString *next = responseObject[@"next"];

        if (next && next != (NSString *)[NSNull null])
        {
            self.nextPage = next;
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
        NSLog(@"Error: %@", error);

        self.nextPage = nil;

        [self.tableView reloadData];
        [self.nextPageSpinner stopAnimating];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [[FPAPIClient sharedClient].operationQueue addOperation:operation];
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
{
    [self objectSelectedAtIndex:index
                  withThumbnail:nil];
}

- (void)objectSelectedAtIndex:(NSInteger)index
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
        FPSourceController *subController = [FPSourceController new];

        subController.path = obj[@"link_path"];
        subController.sourceType = self.sourceType;
        subController.fpdelegate = self.fpdelegate;
        subController.selectMultiple = self.selectMultiple;
        subController.maxFiles = self.maxFiles;

        [self.navigationController pushViewController:subController
                                             animated:YES];

        return;
    }


    if (self.selectMultiple)
    {
        UIView *view = [self.view viewWithTag:CELL_FIRST_TAG + index];

        if ([self.viewType isEqualToString:@"thumbnails"])
        {
            [self toggleSelectionOnThumbnailView:view];
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
        __block FPMBProgressHUD *hud;

        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [FPMBProgressHUD showHUDAddedTo:self.view
                                         animated:YES];

            hud.mode = FPMBProgressHUDModeDeterminate;
            hud.labelText = @"Downloading file";
        });

        FPFetchObjectSuccessBlock successBlock = ^(NSDictionary *data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [FPMBProgressHUD hideAllHUDsForView:self.view
                                           animated:YES];

                [self.fpdelegate FPSourceController:self
                      didFinishPickingMediaWithInfo:data];
            });
        };

        FPFetchObjectFailureBlock failureBlock = ^(NSError *error) {
            NSLog(@"FAIL %@", error);

            if (error.code == kCFURLErrorRedirectToNonExistentLocation ||
                error.code == kCFURLErrorUnsupportedURL)
            {
                [self.navigationController popViewControllerAnimated:YES];

                UIAlertView *message;

                message = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                     message:@"You aren't connected to the internet so we can't get your files."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];

                [message show];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [FPMBProgressHUD hideAllHUDsForView:self.view
                                           animated:YES];

                [self.fpdelegate FPSourceControllerDidCancel:self];
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

- (void)toggleSelectionOnThumbnailView:(UIView *)view
{
    //View is an image view
    UIImageView *imageView = (UIImageView *)view;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *overlay = imageView.subviews[0];

        overlay.hidden = !overlay.hidden;
    });
}

- (void)finishMultipleUpload:(NSArray *)results
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [FPMBProgressHUD hideAllHUDsForView:self.view
                                   animated:YES];

        [self.fpdelegate FPSourceController:nil
         didFinishPickingMultipleMediaWithResults:results];
    });
}

- (void)fetchObject:(NSDictionary *)obj
      withThumbnail:(UIImage *)thumbnail
            success:(FPFetchObjectSuccessBlock)success
            failure:(FPFetchObjectFailureBlock)failure
           progress:(FPFetchObjectProgressBlock)progress
{
    NSLog(@"Selected Contents: %@", obj);

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];

        if (thumbnail)
        {
            mediaInfo[@"FPPickerControllerThumbnailImage"] = thumbnail;
        }

        [self.fpdelegate FPSourceController:self
                       didPickMediaWithInfo:mediaInfo];

        self.view.userInteractionEnabled = NO;
    });

    BOOL shouldDownload = YES;

    if ([self.fpdelegate isKindOfClass:[FPPickerController class]])
    {
        NSLog(@"Should I download?");

        FPPickerController *pickerC = (FPPickerController *)self.fpdelegate;

        shouldDownload = [pickerC shouldDownload];
    }

    if (shouldDownload)
    {
        NSLog(@"Download");

        [self getObjectInfoAndData:obj
                           success:success
                           failure:failure
                          progress:progress];
    }
    else
    {
        NSLog(@"No Download");

        [self getObjectInfo:obj
                    success:success
                    failure:failure
                   progress:progress];
    }
}

- (void)getObjectInfo:(NSDictionary *)obj
              success:(void (^)(NSDictionary *data))success
              failure:(void (^)(NSError *error))failure
             progress:(void (^)(float progress))progress
{
    NSURLRequest *request = [self requestForLoadPath:obj[@"link_path"]
                                          withFormat:@"fpurl"
                                         cachePolicy:NSURLRequestReloadRevalidatingCacheData];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSLog(@"result: %@", responseObject);

        NSDictionary *info = @{
            @"FPPickerControllerRemoteURL":responseObject[@"url"],
            @"FPPickerControllerFilename":responseObject[@"filename"],
            @"FPPickerControllerKey":responseObject[@"key"]
        };

        success(info);
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error);
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [operation setDownloadProgressBlock: ^(NSUInteger bytesRead,
                                           long long totalBytesRead,
                                           long long totalBytesExpectedToRead) {
        if (progress && totalBytesExpectedToRead > 0)
        {
            progress(1.0f * totalBytesRead / totalBytesExpectedToRead);
        }
    }];

    [[FPAPIClient sharedClient].operationQueue addOperation:operation];
}

- (void)getObjectInfoAndData:(NSDictionary *)obj
                     success:(void (^)(NSDictionary *data))success
                     failure:(void (^)(NSError *error))failure
                    progress:(void (^)(float progress))progress
{
    NSURLRequest *request = [self requestForLoadPath:obj[@"link_path"]
                                          withFormat:@"data"
                                         cachePolicy:NSURLRequestReloadRevalidatingCacheData];

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPUtils genRandStringLength:20]];

    NSURL *tempURL = [NSURL fileURLWithPath:tempPath
                                isDirectory:NO];


    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSData *file = [[NSData alloc] initWithContentsOfFile:tempPath];
        NSDictionary *headers = [operation.response allHeaderFields];
        NSString *mimetype = headers[@"Content-Type"];

        // TODO: Should be looking at obj mimetype as well.

        if ([mimetype rangeOfString:@";"].location != NSNotFound)
        {
            mimetype = [mimetype componentsSeparatedByString:@";"][0];
        }

        NSString *UTI = [FPUtils utiForMimetype:mimetype];
        NSMutableDictionary *info;

        info = [NSMutableDictionary dictionaryWithDictionary:@{
                    @"FPPickerControllerRemoteURL":headers[@"X-Data-Url"],
                    @"FPPickerControllerFilename":headers[@"X-File-Name"],
                    @"FPPickerControllerMediaURL":tempURL,
                    @"FPPickerControllerMediaType":UTI
                }];

        if ([FPUtils mimetype:mimetype instanceOfMimetype:@"image/*"])
        {
            info[@"FPPickerControllerOriginalImage"] = [UIImage imageWithData:file];
        }

        if (headers[@"X-Data-Key"])
        {
            info[@"FPPickerControllerKey"] = headers[@"X-Data-Key"];
        }

        success(info);
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error);
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    operation.outputStream = [NSOutputStream outputStreamWithURL:tempURL
                                                          append:NO];

    [operation setDownloadProgressBlock: ^(NSUInteger bytesRead,
                                           long long totalBytesRead,
                                           long long totalBytesExpectedToRead) {
        NSLog(@"Get %ld of %ld bytes", (long)totalBytesRead, (long)totalBytesExpectedToRead);

        if (progress && totalBytesExpectedToRead > 0)
        {
            progress(1.0f * totalBytesRead / totalBytesExpectedToRead);
        }
    }];

    [[FPAPIClient sharedClient].operationQueue addOperation:operation];
}

- (NSURLRequest *)requestForLoadPath:(NSString *)loadpath
                          withFormat:(NSString *)type
                         cachePolicy:(NSURLRequestCachePolicy)policy
{
    return [self requestForLoadPath:loadpath
                         withFormat:type
                        byAppending:@""
                        cachePolicy:policy];
}

- (NSURLRequest *)requestForLoadPath:(NSString *)loadpath
                          withFormat:(NSString *)type
                         byAppending:(NSString *)additionalString
                         cachePolicy:(NSURLRequestCachePolicy)policy
{
    NSString *js_sessionString = [FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                                        andMimetypes:self.sourceType.mimetypes];

    NSString *escapedSessionString = [FPUtils urlEncodeString:js_sessionString];

    NSMutableString *urlString = [NSMutableString stringWithString:[fpBASE_URL stringByAppendingString:[@"/api/path" stringByAppendingString : loadpath]]];

    if ([urlString rangeOfString:@"?"].location == NSNotFound)
    {
        [urlString appendFormat:@"?format=%@&%@=%@", type, @"js_session", escapedSessionString];
    }
    else
    {
        [urlString appendFormat:@"&format=%@&%@=%@", type, @"js_session", escapedSessionString];
    }

    [urlString appendString:additionalString];

    //NSLog(@"Loading Contents from URL: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];


    NSMutableURLRequest *mrequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:policy
                                                        timeoutInterval:240];

    [mrequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:fpCOOKIES]];

    return mrequest;
}

- (void)refresh
{
    [FPMBProgressHUD hideAllHUDsForView:self.view
                               animated:YES];

    [self fpLoadContents:self.path
             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
}

- (void)logout:(NSObject *)button
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/unauth", fpBASE_URL, self.sourceType.identifier];

    NSLog(@"Logout: %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:240];

    [FPMBProgressHUD showHUDAddedTo:self.view
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

        for (NSString *urlString in self.sourceType.externalDomains)
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


        [FPMBProgressHUD hideAllHUDsForView:self.view
                                   animated:YES];

        [self.navigationController popViewControllerAnimated:YES];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        [FPMBProgressHUD hideAllHUDsForView:self.view
                                   animated:YES];

        NSLog(@"error: %@", error);

        UIAlertView *message;

        message = [[UIAlertView alloc] initWithTitle:@"Logout Failure"
                                             message:@"Hmm. We weren't able to logout."
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];

        [message show];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [[FPAPIClient sharedClient].operationQueue addOperation:operation];
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
                                                 name:@"auth"
                                               object:nil];

    FPAuthController *authView = [FPAuthController new];
    authView.service = self.sourceType.identifier;
    authView.title = self.sourceType.name;

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

@end
