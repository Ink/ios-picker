//
//  FPLocalController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPLocalController.h"
#import "FPUtils.h"

typedef void (^FPLocalUploadAssetSuccessBlock)(FPMediaInfo *info);
typedef void (^FPLocalUploadAssetFailureBlock)(NSError *error, FPMediaInfo *info);
typedef void (^FPLocalUploadAssetProgressBlock)(float progress);

@interface FPLocalController ()
{
    UIImage *_selectOverlay;
}

@property int padding;
@property int numPerRow;
@property int thumbSize;
@property UILabel *emptyLabel;
@property NSCache *imageViews;
@property NSMutableSet *selectedAssets;

@end


@implementation FPLocalController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    if (self)
    {
        NSUInteger selectedAssetsCapacity = self.maxFiles == 0 ? 10 : self.maxFiles;

        self.imageViews = [NSCache new];
        self.selectedAssets = [NSMutableSet setWithCapacity:selectedAssetsCapacity];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *imageFilePath = [[FPUtils frameworkBundle] pathForResource:@"SelectOverlayiOS7"
                                                                  ofType:@"png"];

    _selectOverlay = [UIImage imageWithContentsOfFile:imageFilePath];

    NSInteger gCount = [self.assetGroup numberOfAssets];

    self.title = [NSString stringWithFormat:@"%@ (%ld)",
                  [self.assetGroup valueForProperty:ALAssetsGroupPropertyName],
                  (long)gCount];


    // Register for the app switch focus event. Reload the data so things show up immeadiately.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadPhotoData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupLayoutConstants];
    [self loadPhotoData];

    [super viewWillAppear:animated];
}

- (void)loadPhotoData
{
    CGRect bounds = [self getViewBounds];

    self.thumbSize = fpLocalThumbSize;
    self.numPerRow = (int)CGRectGetWidth(bounds) / self.thumbSize;
    self.padding = (int)((CGRectGetWidth(bounds) - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));

    if (self.padding < 4)
    {
        self.numPerRow -= 1;
        self.padding = (int)((CGRectGetWidth(bounds) - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));
    }

    NSLog(@"numperro; %d", self.numPerRow);

    // Just make one instance empty label

    _emptyLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                             CGRectGetMidY(bounds) - 60,
                                                             CGRectGetWidth(bounds),
                                                             30)];

    _emptyLabel.textColor = [UIColor grayColor];
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.text = @"Nothing Available";

    // collect the things

    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];

    [self.assetGroup enumerateAssetsUsingBlock: ^(ALAsset *asset,
                                                  NSUInteger index,
                                                  BOOL *stop) {
        if (asset)
        {
            [collector addObject:asset];
        }
    }];

    NSLog(@"%ld things presented", (unsigned long)collector.count);


    NSArray *reversed = [[collector reverseObjectEnumerator] allObjects];

    [self setPhotos:reversed];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.photos = nil;
    self.fpdelegate = nil;
    self.assetGroup = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self setupLayoutConstants];
    [self.tableView reloadData];
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos)
    {
        _photos = photos;
    }

    // In theory, you should be able to do this only if you update.
    // However, this seems safer to make sure that the empty label gets removed.

    if (_photos.count == 0)
    {
        [self.view addSubview:_emptyLabel];
    }
    else
    {
        [_emptyLabel removeFromSuperview];
    }


    NSUInteger selectedAssetsCapacity = self.maxFiles == 0 ? 10 : self.maxFiles;

    self.imageViews = [NSCache new];
    self.selectedAssets = [NSMutableSet setWithCapacity:selectedAssetsCapacity];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)   tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    return (int)ceilf(1.0f * self.photos.count / self.numPerRow);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];

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
        NSInteger index = self.numPerRow * indexPath.row + i;

        if (self.photos.count <= index)
        {
            break;
        }

        ALAsset *asset = self.photos[index];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];

        [self.imageViews setObject:imageView
                            forKey:@(index)];

        imageView.tag = index;
        imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;

        NSString *uti = asset.defaultRepresentation.UTI;

        if ([uti isEqualToString:@"com.apple.quicktime-movie"])
        {
            //ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSLog(@"data: %@", [asset valueForProperty:ALAssetPropertyDuration]);

            NSString *videoFilePath = [[FPUtils frameworkBundle] pathForResource:@"glyphicons_180_facetime_video"
                                                                          ofType:@"png"];

            UIImage *videoOverlay = [UIImage imageWithContentsOfFile:videoFilePath];
            UIImage *backgroundImage = imageView.image;
            UIImage *watermarkImage = videoOverlay;

            UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                              backgroundImage.size.height - 10,
                                                                              backgroundImage.size.width,
                                                                              10)];
            headingLabel.textColor = [UIColor whiteColor];
            headingLabel.backgroundColor = [UIColor blackColor];
            headingLabel.alpha = 0.7;
            headingLabel.font = [UIFont systemFontOfSize:14];
            headingLabel.textAlignment = NSTextAlignmentRight;
            headingLabel.text = [FPUtils formatTimeInSeconds:ceil([[asset valueForProperty:ALAssetPropertyDuration] doubleValue])];


            UIImage *result;

            UIGraphicsBeginImageContext(backgroundImage.size);
            {
                [backgroundImage drawInRect:CGRectMake(0,
                                                       0,
                                                       backgroundImage.size.width,
                                                       backgroundImage.size.height)];

                [watermarkImage drawInRect:CGRectMake(5,
                                                      backgroundImage.size.height - watermarkImage.size.height - 5,
                                                      watermarkImage.size.width,
                                                      watermarkImage.size.height)];

                [headingLabel drawTextInRect:CGRectMake(0,
                                                        backgroundImage.size.height - watermarkImage.size.height - 3,
                                                        backgroundImage.size.width - 5,
                                                        10)];

                result = UIGraphicsGetImageFromCurrentImageContext();
            }
            UIGraphicsEndImageContext();

            imageView.image = result;
        }

        if (self.selectMultiple)
        {
            // Add overlay

            UIImageView *overlay = [[UIImageView alloc] initWithImage:_selectOverlay];

            // If this asset is selected, leave the overlay on.

            overlay.hidden = ![self.selectedAssets containsObject:asset];
            overlay.opaque = NO;

            [imageView addSubview:overlay];
        }


        [cell.contentView addSubview:imageView];

        rect.origin.x += self.thumbSize + self.padding;
    }

    return cell;
}

- (CGFloat)       tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.thumbSize + self.padding;
}

#pragma mark - Table view delegate

- (IBAction)singleTappedWithGesture:(UIGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationOfTouch:sender.view.tag inView:sender.view];

    int colIndex = (int)fmin(floor(tapPoint.x / (self.thumbSize + self.padding)), self.numPerRow - 1);

    // Do nothing if there isn't a corresponding image view.

    if (colIndex >= sender.view.subviews.count)
    {
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImageView *selectedView = sender.view.subviews[colIndex];

        [self objectSelectedAtIndex:selectedView.tag];
    });
}

- (void)objectSelectedAtIndex:(NSInteger)index
{
    ALAsset *asset = self.photos[index];

    NSLog(@"Selection at Index: %ld", (long)index);

    if (self.selectMultiple)
    {
        [self toggleSelectedImageOnView:[self.imageViews objectForKey:@(index)]];
        [self toggleSelection:asset];
    }
    else
    {
        __block MBProgressHUD *hud;

        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                                       animated:YES];

            hud.labelText = @"Uploading file";
            hud.mode = MBProgressHUDModeDeterminate;
        });

        FPLocalUploadAssetSuccessBlock successBlock = ^(FPMediaInfo *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                         animated:YES];

                [self.fpdelegate sourceController:nil
                    didFinishPickingMediaWithInfo:info];
            });
        };

        FPLocalUploadAssetFailureBlock failureBlock = ^(NSError *error,
                                                        FPMediaInfo *info) {
            NSLog(@"Error %@:", error);

            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                         animated:YES];

                if (!info)
                {
                    [self.fpdelegate sourceControllerDidCancel:nil];
                }
                else
                {
                    [self.fpdelegate sourceController:nil
                        didFinishPickingMediaWithInfo:info];
                }
            });
        };

        FPLocalUploadAssetProgressBlock progressBlock = ^(float progress) {
            hud.progress = progress;
        };

        [self uploadAsset:asset
                  success:successBlock
                  failure:failureBlock
                 progress:progressBlock];
    }
}

- (void)toggleSelection:(ALAsset *)asset
{
    if ([self.selectedAssets containsObject:asset])
    {
        [self.selectedAssets removeObject:asset];
    }
    else
    {
        [self.selectedAssets addObject:asset];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUploadButton:self.selectedAssets.count];
    });
}

- (void)toggleSelectedImageOnView:(UIImageView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *overlay = view.subviews[0];
        overlay.hidden = !overlay.hidden;
    });
}

- (IBAction)uploadButtonTapped:(id)sender
{
    [super uploadButtonTapped:sender];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                                              animated:YES];

    hud.mode = MBProgressHUDModeDeterminate;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.selectedAssets.count];

    __block NSInteger totalCount = self.selectedAssets.count;
    __block NSInteger failedCount = 0;

    if (totalCount == 1)
    {
        hud.labelText = @"Uploading 1 file";
    }
    else
    {
        hud.labelText = [NSString stringWithFormat:@"Uploading 1 of %ld files", (long)totalCount];
    }

    FPProgressTracker *progressTracker = [[FPProgressTracker alloc] initWithObjectCount:self.selectedAssets.count];

    for (ALAsset *asset in self.selectedAssets)
    {
        NSString *progressKey = [FPUtils uuidString];

        // We push all the uploads onto background threads. Now we have to be careful
        // as we're working in multi-threaded environment.

        FPLocalUploadAssetSuccessBlock successBlock = ^(FPMediaInfo *info) {
            @synchronized(results)
            {
                [results addObject:info];

                // OK to do from background thread

                hud.progress = [progressTracker setProgress:1.f
                                                     forKey:progressKey];

                // Check >= in case we miss (we shouldn't, but hey, better safe than sorry)

                if (results.count >= totalCount)
                {
                    hud.labelText = @"Finished uploading";

                    [self finishMultipleUpload:results];
                }
                else
                {
                    hud.labelText = [NSString stringWithFormat:@"Uploading %ld of %ld files", results.count + 1l, (long)totalCount];
                }
            }
        };

        FPLocalUploadAssetFailureBlock failureBlock = ^(NSError *error,
                                                        FPMediaInfo *info) {
            // Carry on!

            NSLog(@"Had an error while uploading multiple files, pressing onwards. Error was %@, info was %@",
                  error,
                  info);

            @synchronized(results)
            {
                if (!info)
                {
                    // Skip it

                    totalCount--;
                    failedCount++;

                    if (failedCount == 1)
                    {
                        hud.detailsLabelText = @"1 file failed";
                    }
                    else
                    {
                        hud.detailsLabelText = [NSString stringWithFormat:@"%ld files failed", (long)failedCount];
                    }
                }
                else
                {
                    [results addObject:info];
                }

                // OK to do from background thread

                hud.progress = [progressTracker setProgress:1.f
                                                     forKey:progressKey];

                if (results.count >= totalCount)
                {
                    [self finishMultipleUpload:results];
                }
                else
                {
                    hud.labelText = [NSString stringWithFormat:@"Uploading %ld of %ld files", (unsigned long)results.count, (long)totalCount];
                }
            }
        };

        FPLocalUploadAssetProgressBlock progressBlock = ^(float progress) {
            hud.progress = [progressTracker setProgress:progress
                                                 forKey:progressKey];
        };

        dispatch_after(popTime,
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       ^(void) {
            [self uploadAsset:asset
                      success:successBlock
                      failure:failureBlock
                     progress:progressBlock];
        });
    }
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

- (void)uploadAsset:(ALAsset *)asset
            success:(FPLocalUploadAssetSuccessBlock)success
            failure:(FPLocalUploadAssetFailureBlock)failure
           progress:(FPLocalUploadAssetProgressBlock)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        FPMediaInfo *mediaInfo = [FPMediaInfo new];

        mediaInfo.thumbnailImage = [UIImage imageWithCGImage:asset.thumbnail];

        [self.fpdelegate sourceController:nil
                     didPickMediaWithInfo:mediaInfo];
    });

    NSLog(@"Asset: %@", asset);

    BOOL shouldUpload = YES;

    if ([self.fpdelegate isKindOfClass:[FPPickerController class]])
    {
        NSLog(@"Should I upload?");
        FPPickerController *pickerC = (FPPickerController *)self.fpdelegate;

        shouldUpload = [pickerC shouldUpload];
    }

    NSLog(@"should upload: %@", shouldUpload ? @"YES" : @"NO");

    if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqual:(NSString *)ALAssetTypePhoto])
    {
        [self uploadPhotoAsset:asset
                  shouldUpload:shouldUpload
                       success:success
                       failure:failure
                      progress:progress];
    }
    else if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqual:(NSString *)ALAssetTypeVideo])
    {
        [self uploadVideoAsset:asset
                  shouldUpload:shouldUpload
                       success:success
                       failure:failure
                      progress:progress];
    }
    else
    {
        NSLog(@"Type: %@", [asset valueForProperty:@"ALAssetPropertyType"]);
        NSLog(@"Didnt handle");

        failure([FPUtils errorWithCode:200
                 andLocalizedDescription:@"Invalid asset type"],
                nil);
    }
}

- (void)uploadPhotoAsset:(ALAsset *)asset
            shouldUpload:(BOOL)shouldUpload
                 success:(FPLocalUploadAssetSuccessBlock)success
                 failure:(FPLocalUploadAssetFailureBlock)failure
                progress:(FPLocalUploadAssetProgressBlock)progress
{
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    FPMediaInfo *mediaInfo = [FPMediaInfo new];

    mediaInfo.mediaType = (NSString *)kUTTypeImage;
    mediaInfo.originalAsset = asset;

    FPUploadAssetSuccessWithLocalURLBlock successBlock = ^(id JSON,
                                                           NSURL *localURL) {
        NSDictionary *data = JSON[@"data"][0][@"data"];

        mediaInfo.mediaURL = localURL;
        mediaInfo.remoteURL = [NSURL URLWithString:JSON[@"data"][0][@"url"]];
        mediaInfo.filename = data[@"filename"];
        mediaInfo.key = data[@"key"];
        mediaInfo.filesize = data[@"size"];

        success(mediaInfo);
    };

    FPUploadAssetFailureWithLocalURLBlock failureBlock = ^(NSError *error,
                                                           id JSON,
                                                           NSURL *localURL) {
        mediaInfo.mediaURL = localURL;
        mediaInfo.filename = representation.filename;

        failure(error, mediaInfo);
    };

    [FPLibrary uploadAsset:asset
               withOptions:nil
              shouldUpload:shouldUpload
                   success:successBlock
                   failure:failureBlock
                  progress:progress];
}

- (void)uploadVideoAsset:(ALAsset *)asset
            shouldUpload:(BOOL)shouldUpload
                 success:(FPLocalUploadAssetSuccessBlock)success
                 failure:(FPLocalUploadAssetFailureBlock)failure
                progress:(FPLocalUploadAssetProgressBlock)progress
{
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    FPMediaInfo *mediaInfo = [FPMediaInfo new];

    mediaInfo.mediaType = (NSString *)kUTTypeVideo;
    mediaInfo.originalAsset = asset;
    mediaInfo.source = self.source;

    FPUploadAssetSuccessWithLocalURLBlock successBlock = ^(id JSON,
                                                           NSURL *localURL) {
        NSDictionary *data = JSON[@"data"][0][@"data"];

        mediaInfo.mediaURL = localURL;
        mediaInfo.remoteURL = [NSURL URLWithString:JSON[@"data"][0][@"url"]];
        mediaInfo.filename = data[@"filename"];
        mediaInfo.key = data[@"key"];
        mediaInfo.filesize = data[@"size"];

        success(mediaInfo);
    };

    FPUploadAssetFailureWithLocalURLBlock failureBlock = ^(NSError *error,
                                                           id JSON,
                                                           NSURL *localURL) {
        mediaInfo.mediaURL = localURL;
        mediaInfo.filename = representation.filename;

        failure(error, mediaInfo);
    };

    [FPLibrary uploadAsset:asset
               withOptions:nil
              shouldUpload:shouldUpload
                   success:successBlock
                   failure:failureBlock
                  progress:progress];
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

- (void)setupLayoutConstants
{
    CGSize screenSize = [self getViewBounds].size;

    self.thumbSize = fpLocalThumbSize;
    self.numPerRow = (int)screenSize.width / self.thumbSize;
    self.padding = (int)((screenSize.width - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));

    if (self.padding < 4)
    {
        self.numPerRow -= 1;
        self.padding = (int)((screenSize.width - self.numPerRow * self.thumbSize) / (self.numPerRow + 1.0f));
    }
}

@end
