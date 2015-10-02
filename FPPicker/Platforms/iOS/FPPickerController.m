//
//  NavigationController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPPickerController.h"
#import "FPImagePickerController.h"
#import "FPInternalHeaders.h"
#import "FPTheme.h"
#import "FPThemeApplier.h"

@interface FPPickerController () <UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate,
                                  FPSourceControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *uploadOperationQueue;
@property (nonatomic, strong) FPThemeApplier *themeApplier;

@end

@implementation FPPickerController

#pragma mark - Accessors

- (void)setTheme:(FPTheme *)theme
{
    _theme = theme;

    // Apply theme
    self.themeApplier = [[FPThemeApplier alloc] initWithTheme:theme];

    if (self.isViewLoaded)
    {
        [self.themeApplier applyToController:self];
    }
}

- (NSOperationQueue *)uploadOperationQueue
{
    if (!_uploadOperationQueue)
    {
        _uploadOperationQueue = [NSOperationQueue new];
    }

    return _uploadOperationQueue;
}

#pragma mark - Constructors / Destructor

- (void)initializeProperties
{
    self.allowsEditing = NO;
    self.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.videoMaximumDuration = 600;
    self.showsCameraControls = YES;
    self.cameraOverlayView = nil;
    self.cameraViewTransform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;

    self.selectMultiple = NO;
    self.maxFiles = 0;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        [self initializeProperties];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    [self initializeProperties];

    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];

    [self initializeProperties];

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    [self initializeProperties];

    return self;
}

#pragma mark - Other Methods

- (void)viewDidLoad
{
    [self.themeApplier applyToController:self];
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    self.delegate = self;

    if (!fpAPIKEY ||
        [fpAPIKEY isEqualToString:@""] ||
        [fpAPIKEY isEqualToString:@"SET_FILEPICKER.IO_APIKEY_HERE"])
    {
        NSException *apikeyException = [NSException
                                        exceptionWithName:@"Filepicker Configuration Error"
                                                   reason:@"APIKEY not set. You can get one at https://www.filepicker.io and insert it into your project's info.plist as 'Filepicker API Key'"
                                                 userInfo:nil];
        [apikeyException raise];
    }

    FPSourceListController *fpSourceListController = [FPSourceListController new];

    fpSourceListController.fpdelegate = self;
    fpSourceListController.imageDelegate = self;
    fpSourceListController.sourceNames = _sourceNames;
    fpSourceListController.dataTypes = _dataTypes;
    fpSourceListController.selectMultiple = _selectMultiple;
    fpSourceListController.maxFiles = _maxFiles;
    fpSourceListController.title = self.title;

    [self pushViewController:fpSourceListController
                    animated:YES];
}

#pragma mark UIImagePickerControllerDelegate Methods

- (void)    imagePickerController:(FPImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /* resizing the thumbnail */

    UIImage *originalImage, *editedImage, *imageToSave;

    editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
    originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];

    if (editedImage)
    {
        NSLog(@"USING EDITED IMAGE");

        imageToSave = editedImage;
    }
    else
    {
        NSLog(@"USING ORIGINAL IMAGE");

        imageToSave = originalImage;
    }

    const CGFloat ThumbnailSize = 115.0f;
    CGFloat scaleFactor = ThumbnailSize / MIN(imageToSave.size.height, imageToSave.size.width);
    CGFloat newHeight = imageToSave.size.height * scaleFactor;
    CGFloat newWidth = imageToSave.size.width * scaleFactor;
    UIImage *thumbImage;

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    {
        [imageToSave drawInRect:CGRectMake(0, 0, newWidth, newHeight)];

        thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();

    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpPickerController:didPickMediaWithInfo:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            FPMediaInfo *mediaInfo = [FPMediaInfo new];

            mediaInfo.thumbnailImage = thumbImage;

            [self.fpdelegate fpPickerController:self
                           didPickMediaWithInfo :mediaInfo];
        });
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:picker.view
                                              animated:YES];

    hud.labelText = @"Uploading...";
    hud.mode = MBProgressHUDModeDeterminate;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        FPMediaInfo *mediaInfo = [FPMediaInfo new];

        mediaInfo.mediaType = info[@"UIImagePickerControllerMediaType"];

        NSLog(@"Picked something from local camera: %@ %@", info, mediaInfo.mediaType);

        FPUploadAssetSuccessWithLocalURLBlock successBlock = ^(id JSON,
                                                               NSURL *localURL) {
            NSLog(@"JSON: %@", JSON);

            NSDictionary *data = JSON[@"data"][0][@"data"];

            mediaInfo.mediaURL = localURL;
            mediaInfo.remoteURL = [NSURL URLWithString:JSON[@"data"][0][@"url"]];
            mediaInfo.filename = data[@"filename"];
            mediaInfo.key = data[@"key"];
            mediaInfo.filesize = data[@"size"];
            mediaInfo.source = picker.source;

            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:picker.view
                                     animated:YES];

                [picker dismissViewControllerAnimated:NO
                                           completion: ^{
                    [self.fpdelegate fpPickerController:self
                          didFinishPickingMediaWithInfo:mediaInfo];
                }];
            });
        };

        FPUploadAssetFailureWithLocalURLBlock failureBlock = ^(NSError *error,
                                                               id JSON,
                                                               NSURL *localURL) {
            mediaInfo.mediaURL = localURL;

            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view
                                     animated:YES];

                [picker dismissViewControllerAnimated:NO
                                           completion: ^{
                    [self.fpdelegate fpPickerController:self
                          didFinishPickingMediaWithInfo:mediaInfo];
                }];
            });
        };

        FPUploadAssetProgressBlock progressBlock = ^(float progress) {
            hud.progress = progress;
        };

        if ([info[@"UIImagePickerControllerMediaType"] isEqual:(NSString *)kUTTypeImage])
        {
            NSString *dataType = @"image/jpeg";

            [FPLibrary uploadImage:imageToSave
                        ofMimetype:dataType
               usingOperationQueue:self.uploadOperationQueue
                           success:successBlock
                           failure:failureBlock
                          progress:progressBlock];
        }
        else if ([info[@"UIImagePickerControllerMediaType"] isEqual:(NSString *)kUTTypeMovie])
        {
            NSURL *url = info[@"UIImagePickerControllerMediaURL"];

            [FPLibrary uploadVideoURL:url
                  usingOperationQueue:self.uploadOperationQueue
                              success:successBlock
                              failure:failureBlock
                             progress:progressBlock];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error. We couldn't handle this file %@", info);
                NSLog(@"Type: %@", info[@"UIImagePickerControllerMediaType"]);

                [MBProgressHUD hideHUDForView:self.view
                                     animated:YES];

                [picker dismissViewControllerAnimated:NO
                                           completion: ^{
                    [self.fpdelegate fpPickerControllerDidCancel:self];
                }];
            });
        }
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // The user chose to cancel when using the camera.

    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

#pragma mark FPSourcePickerDelegate Methods

- (void)sourceController:(FPSourceController *)sourceController
    didPickMediaWithInfo:(FPMediaInfo *)info
{
    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpPickerController:didPickMediaWithInfo:)])
    {
        [self.fpdelegate fpPickerController:self
                       didPickMediaWithInfo :info];
    }
}

- (void)         sourceController:(FPSourceController *)sourceController
    didFinishPickingMediaWithInfo:(FPMediaInfo *)info
{
    // The user chose a file from the cloud or camera roll.

    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpPickerController:didFinishPickingMediaWithInfo:)])
    {
        [self.fpdelegate fpPickerController:self
              didFinishPickingMediaWithInfo:info];
    }
}

- (void)                    sourceController:(FPSourceController *)sourceController
    didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    // The user chose a file from the cloud or camera roll.

    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpPickerController:didFinishPickingMultipleMediaWithResults:)])
    {
        [self.fpdelegate fpPickerController:self
         didFinishPickingMultipleMediaWithResults:results];
    }
}

- (void)sourceControllerDidCancel:(FPSourceController *)sourceController
{
    // The user chose to cancel when using the cloud or camera roll.

    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpPickerControllerDidCancel:)])
    {
        [self.fpdelegate fpPickerControllerDidCancel:self];
    }
}

#pragma mark UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    return;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    return;
}

@end
