//
//  FPLocalController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPLocalController.h"
#import "FPProgressTracker.h"

@interface FPLocalController ()

@property int padding;
@property int numPerRow;
@property int thumbSize;
@property UILabel *emptyLabel;
@property NSMutableArray *imageViews;
@property NSMutableSet *selectedAssets;
@property UITableView *tableView;

@end

@implementation FPLocalController

@synthesize photos = _photos;
@synthesize fpdelegate;
@synthesize assetGroup = _assetGroup;
@synthesize padding, numPerRow, thumbSize;
@synthesize emptyLabel = _emptyLabel;

@synthesize imageViews = _imageViews;
@synthesize selectedAssets = _selectedAssets;
@synthesize tableView = _tableView;

UIImage *selectOverlay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imageViews = [NSMutableArray array];
        self.selectedAssets = [NSMutableSet setWithCapacity:self.maxFiles == 0 ? 10 : self.maxFiles];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        selectOverlay = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"SelectOverlayiOS7" ofType:@"png"]];
    } else {
        selectOverlay = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"SelectOverlay" ofType:@"png"]];
    }
    
    NSInteger gCount = [self.assetGroup numberOfAssets];

    self.title = [NSString stringWithFormat:@"%@ (%ld)",[self.assetGroup valueForProperty:ALAssetsGroupPropertyName], (long)gCount];
    
    //Register for the app switch focus event. Reload the data so things show up immeadiately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhotoData) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated  {
    [self loadPhotoData];
    
    [super viewWillAppear:animated];
}


- (void) loadPhotoData {
    
    self.contentSizeForViewInPopover = fpWindowSize;
    
    CGRect bounds = [self getViewBounds];
    self.thumbSize = fpLocalThumbSize;
    self.numPerRow = (int) bounds.size.width/self.thumbSize;
    self.padding = (int)((bounds.size.width - numPerRow*self.thumbSize)/ ((float)numPerRow + 1));
    if (padding < 4){
        self.numPerRow -= 1;
        self.padding = (int)((bounds.size.width - numPerRow*self.thumbSize)/ ((float)numPerRow + 1));
    }
    NSLog(@"numperro; %d", self.numPerRow);

    //Just make one instance empty label
    _emptyLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, (bounds.size.height)/2-60, bounds.size.width, 30)];
    [_emptyLabel setTextColor:[UIColor grayColor]];
    [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
    [_emptyLabel setText:@"Nothing Available"];
    
    // collect the things
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
      if (asset) {
          [collector addObject:asset];
      }
    }];
    NSLog(@"%ld things presented", (unsigned long)[collector count]);
    NSArray* reversed = [[collector reverseObjectEnumerator] allObjects];

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


-(void)setPhotos:(NSArray *)photos {

    if (_photos != photos) {
        _photos = photos;
    }

    // In theory, you should be able to do this only if you update.
    // However, this seems safer to make sure that the empty label gets removed.
    if ([_photos count] == 0) {
        [self.view addSubview:_emptyLabel];
    } else {
        [_emptyLabel removeFromSuperview];
    }
    self.imageViews = [NSMutableArray array];
    self.selectedAssets = [NSMutableSet setWithCapacity:self.maxFiles == 0 ? 10 : self.maxFiles];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (int)ceil([self.photos count]/(self.numPerRow*1.0));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTappedWithGesture:)];
    [cell.contentView addGestureRecognizer:tap];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGRect rect = CGRectMake(self.padding, self.padding, self.thumbSize, self.thumbSize);
    
    for (int i=0; i<self.numPerRow; i++) {
        NSInteger index = self.numPerRow*indexPath.row + i;
        NSLog(@"Index %ld", (long)index);
        if (index >= [self.photos count]){
            break;
        }
        
        ALAsset *asset = [self.photos objectAtIndex:index];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
        [self.imageViews setObject:image atIndexedSubscript:index];
        image.tag = index;
        image.image = [UIImage imageWithCGImage:[asset thumbnail]];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        
        NSString *uti = [[asset defaultRepresentation] UTI];
        if ([uti isEqualToString:@"com.apple.quicktime-movie"]){
            //ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSLog(@"data: %@", [asset valueForProperty:ALAssetPropertyDuration]);
            UIImage *videoOverlay = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"glyphicons_180_facetime_video" ofType:@"png"]];
            
            UIImage *backgroundImage = image.image;
            UIImage *watermarkImage = videoOverlay;
            
            UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, backgroundImage.size.height - 10, backgroundImage.size.width, 10)];
            [headingLabel setTextColor:[UIColor whiteColor]];
            [headingLabel setBackgroundColor:[UIColor blackColor]];
            [headingLabel setAlpha:0.7];
            [headingLabel setFont:[UIFont systemFontOfSize:14]];
            [headingLabel setTextAlignment:NSTextAlignmentRight];
            headingLabel.text = [FPLibrary formatTimeInSeconds: ceil([[asset valueForProperty:ALAssetPropertyDuration] doubleValue])];

            
            UIGraphicsBeginImageContext(backgroundImage.size);
            [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
            [watermarkImage drawInRect:CGRectMake(5, backgroundImage.size.height - watermarkImage.size.height - 5, watermarkImage.size.width, watermarkImage.size.height)];
            [headingLabel drawTextInRect:CGRectMake(0, backgroundImage.size.height - watermarkImage.size.height -3 , backgroundImage.size.width-5, 10)];
            
            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            image.image = result;
            
        }
        
        if (self.selectMultiple) {
            //Add overlay
            UIImageView *overlay = [[UIImageView alloc] initWithImage:selectOverlay];
            
            //If this asset is selected, leave the overlay on.
            overlay.hidden = ![self.selectedAssets containsObject:asset];
            
            overlay.opaque = NO;
            [image addSubview:overlay];
        }

        
        [cell.contentView addSubview:image];
        rect = CGRectMake((rect.origin.x+self.thumbSize+self.padding), rect.origin.y, rect.size.width, rect.size.height);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.thumbSize + self.padding;
}

#pragma mark - Table view delegate

- (IBAction)singleTappedWithGesture:(UIGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationOfTouch:sender.view.tag inView:sender.view];
    
    int colIndex = (int) fmin(floor(tapPoint.x/(self.thumbSize+self.padding)), self.numPerRow-1);
    
    //Do nothing if there isn't a corresponding image view.
    if (colIndex >= [sender.view.subviews count]){
        return;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        UIImageView *selectedView = [sender.view.subviews objectAtIndex:colIndex];
        [self objectSelectedAtIndex:selectedView.tag];    
    });
}

- (void) objectSelectedAtIndex:(NSInteger) index {
    ALAsset* asset = [self.photos objectAtIndex:index];
    NSLog(@"Selection at Index: %ld", (long)index);
    if (self.selectMultiple) {
        [self toggleSelectedImageOnView:[self.imageViews objectAtIndex:index]];
        [self toggleSelection:asset];
    } else {
        FPMBProgressHUD __block *hud;
        dispatch_async(dispatch_get_main_queue(),^{
            hud = [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Uploading file";
            hud.mode = FPMBProgressHUDModeDeterminate;
        });
        
        [self uploadAsset:asset success:^(NSDictionary *data) {
            dispatch_async(dispatch_get_main_queue(),^{
                [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [fpdelegate FPSourceController:nil didFinishPickingMediaWithInfo:data];
            });
        } failure:^(NSError *error, NSDictionary *data) {
            NSLog(@"Error %@:", error);
            dispatch_async(dispatch_get_main_queue(),^{
                [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (data == nil) {
                    [fpdelegate FPSourceControllerDidCancel:nil];
                } else {
                    [fpdelegate FPSourceController:nil didFinishPickingMediaWithInfo:data];
                }
            });
        } progress:^(float progress) {
            hud.progress = progress;
        }];
    }
}

- (void) toggleSelection:(ALAsset*)asset {
    if ([self.selectedAssets containsObject:asset]) {
        [self.selectedAssets removeObject:asset];
    } else {
        [self.selectedAssets addObject:asset];
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [self updateUploadButton:self.selectedAssets.count];
    });
}

- (void) toggleSelectedImageOnView:(UIImageView*) view {
    dispatch_async(dispatch_get_main_queue(),^{
        UIView* overlay = [view.subviews objectAtIndex:0];
        overlay.hidden = !overlay.hidden;
    });
}

- (void) uploadButtonTapped:(id)sender {
    [super uploadButtonTapped:sender];
    
    FPMBProgressHUD *hud = [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = FPMBProgressHUDModeDeterminate;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:self.selectedAssets.count];

    NSInteger __block totalCount = self.selectedAssets.count;
    NSInteger __block failedCount = 0;
    
    if (totalCount == 1) {
        hud.labelText = @"Uploading 1 file";
    } else {
        hud.labelText = [NSString stringWithFormat:@"Uploading 1 of %ld files", (long)totalCount];
    }
    
    FPProgressTracker *progressTracker = [[FPProgressTracker alloc] initWithObjectCount:self.selectedAssets.count];
    
    for (ALAsset* asset in self.selectedAssets) {
        NSURL *progressKey = [asset defaultRepresentation].url;
        //We push all the uploads onto background threads. Now we have to be careful
        //as we're working in multi-threaded environment.
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            [self uploadAsset:asset success:^(NSDictionary *data) {
                @synchronized(results){
                    [results addObject:data];
                    //OK to do from background thread
                    hud.progress = [progressTracker setProgress:1.f forKey:progressKey];
                    //Check >= in case we miss (we shouldn't, but hey, better safe than sorry)
                    if (results.count >= totalCount) {
                        hud.labelText = @"Finished uploading";
                        [self finishMultipleUpload:results];
                    } else {
                        hud.labelText = [NSString stringWithFormat:@"Uploading %ld of %ld files", results.count + 1l, (long)totalCount];
                    }
                }
            } failure:^(NSError *error, NSDictionary *data) {
                //Carry on!
                NSLog(@"Had an error while uploading multiple files, pressing onwards. Error was %@, data was %@", error, data);
                @synchronized(results){
                    if (data == nil) {
                        //Skip it
                        totalCount--;
                        failedCount++;
                        if (failedCount == 1) {
                            hud.detailsLabelText = @"1 file failed";
                        } else {
                            hud.detailsLabelText = [NSString stringWithFormat:@"%ld files failed", (long)failedCount];
                        }
                    } else {
                        [results addObject:data];
                    }
                    //OK to do from background thread
                    hud.progress = [progressTracker setProgress:1.f forKey:progressKey];
                    
                    if (results.count >= totalCount) {
                        [self finishMultipleUpload:results];
                    } else {
                        hud.labelText = [NSString stringWithFormat:@"Uploading %ld of %ld files", (unsigned long)results.count, (long)totalCount];
                    }
                }
            } progress:^(float progress) {
                hud.progress = [progressTracker setProgress:progress forKey:progressKey];
            }];
        });
    }
}

- (void) finishMultipleUpload:(NSArray*) results {
    dispatch_async(dispatch_get_main_queue(),^{
        [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [fpdelegate FPSourceController:nil didFinishPickingMultipleMediaWithResults:results];
    });
}

- (NSString*) getFilenameForAssetRepresentation:(ALAssetRepresentation*) representation {
    if ([representation respondsToSelector:@selector(filename)]){
        return [representation filename];
    } else {
        NSString *extension = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)[representation UTI], kUTTagClassFilenameExtension);
        return [NSString stringWithFormat:@"file.%@", extension];
    }
}

- (void) uploadAsset:(ALAsset*) asset
             success:(void (^)(NSDictionary *data))success
             failure:(void (^)(NSError *error, NSDictionary *data))failure
            progress:(void (^)(float progress))progress
{
    dispatch_async(dispatch_get_main_queue(),^{
        [fpdelegate FPSourceController:nil didPickMediaWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIImage imageWithCGImage:[asset thumbnail]], @"FPPickerControllerThumbnailImage" , nil]];
    });
    
    NSLog(@"Asset: %@", asset);

    BOOL shouldUpload = YES;
    if ([fpdelegate isKindOfClass:[FPPickerController class]]){
        NSLog(@"Should I upload?");
        FPPickerController *pickerC = (FPPickerController *)fpdelegate;
        shouldUpload = [pickerC shouldUpload];
    }

    NSLog(@"should upload: %@", shouldUpload?@"YES":@"NO");
    
    if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqual:(NSString*) ALAssetTypePhoto]){
        [self uploadPhotoAsset:asset shouldUpload:shouldUpload success:success failure:failure progress:progress];
    } else if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqual:(NSString*) ALAssetTypeVideo]){
        [self uploadVideoAsset:asset shouldUpload:shouldUpload success:success failure:failure progress:progress];
    } else {
        NSLog(@"Type: %@", [asset valueForProperty:@"ALAssetPropertyType"]);
        NSLog(@"Didnt handle");

        failure([NSError errorWithDomain:@"iOS-picker" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Invalid asset type", }], nil);
    }
}

- (void) uploadPhotoAsset:(ALAsset*) asset shouldUpload:(BOOL)shouldUpload
                  success:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSError *error, NSDictionary *data))failure
                 progress:(void (^)(float progress))progress
{
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    UIImage* image = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                        scale:[representation scale] orientation:(UIImageOrientation)[representation orientation]];
        
    NSLog(@"uti: %@", [representation UTI]);
    NSString *filename = [self getFilenameForAssetRepresentation:representation];
    
    [FPLibrary uploadAsset:asset withOptions:[[NSDictionary alloc] init] shouldUpload:shouldUpload success:^(id JSON, NSURL *localurl) {
        NSDictionary *output = [[NSDictionary alloc] initWithObjectsAndKeys:
                                (NSString*) kUTTypeImage, @"FPPickerControllerMediaType",
                                image, @"FPPickerControllerOriginalImage",
                                localurl, @"FPPickerControllerMediaURL",
                                [[[JSON objectForKey:@"data"]  objectAtIndex:0] objectForKey:@"url"], @"FPPickerControllerRemoteURL",
                                [[[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"data"] objectForKey:@"filename"], @"FPPickerControllerFilename",
                                [[[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"data"] objectForKey:@"key"], @"FPPickerControllerKey",
                                nil];
        success(output);
    } failure:^(NSError *error, id JSON, NSURL *localurl) {
        NSDictionary *output = [[NSDictionary alloc] initWithObjectsAndKeys:
                                (NSString*) kUTTypeImage, @"FPPickerControllerMediaType",
                                image, @"FPPickerControllerOriginalImage",
                                localurl, @"FPPickerControllerMediaURL",
                                @"", @"FPPickerControllerRemoteURL",
                                filename, @"FPPickerControllerFilename",
                                nil];
        failure(error, output);
    } progress:progress];
}

- (void) uploadVideoAsset:(ALAsset*) asset shouldUpload:(BOOL)shouldUpload
                  success:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSError *error, NSDictionary *data))failure
                 progress:(void (^)(float progress))progress {
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSString *filename = [self getFilenameForAssetRepresentation:representation];
    
    [FPLibrary uploadAsset:asset withOptions:[[NSDictionary alloc] init] shouldUpload:shouldUpload success:^(id JSON, NSURL *localurl) {
        NSDictionary *output = [[NSDictionary alloc] initWithObjectsAndKeys:
                                (NSString *) kUTTypeVideo , @"FPPickerControllerMediaType",
                                localurl, @"FPPickerControllerMediaURL",
                                [[[JSON objectForKey:@"data"]  objectAtIndex:0] objectForKey:@"url"], @"FPPickerControllerRemoteURL",
                                [[[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"data"] objectForKey:@"filename"], @"FPPickerControllerFilename",
                                [[[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"data"] objectForKey:@"key"], @"FPPickerControllerKey",
                                nil];
        success(output);
    } failure:^(NSError *error, id JSON, NSURL *localurl) {
        NSDictionary *output = [[NSDictionary alloc] initWithObjectsAndKeys:
                                (NSString *) kUTTypeVideo , @"FPPickerControllerMediaType",
                                localurl, @"FPPickerControllerMediaURL",
                                @"", @"FPPickerControllerRemoteURL",
                                filename, @"FPPickerControllerFilename",
                                nil];
        failure(error, output);
    } progress:progress];
}


- (CGRect)getViewBounds {
    CGRect bounds = self.view.bounds;
    
    UIView *parent = self.view.superview;
	if (parent) {
		bounds = parent.bounds;
	}
    return bounds;
}

@end
