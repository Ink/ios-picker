//
//  NavigationController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPInternalHeaders.h"
#import "FPPickerController.h"
#import "FPSourceListController.h"


@interface FPPickerController ()

@property BOOL hasStatusBar;

@end

@implementation FPPickerController

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

    self.shouldUpload = YES;
    self.shouldDownload = YES;

    self.selectMultiple = NO;
    self.maxFiles = 0;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        [self initializeProperties];

        CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);

        if (statusBarHeight < 0.0001)
        {
            self.hasStatusBar = NO;
        }
        else
        {
            self.hasStatusBar = YES;
        }
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    [self initializeProperties];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;

    if (fpAPIKEY == NULL || [fpAPIKEY isEqualToString:@""] || [fpAPIKEY isEqualToString:@"SET_FILEPICKER.IO_APIKEY_HERE"])
    {
        NSException *apikeyException = [NSException
                                        exceptionWithName:@"Filepicker Configuration Error"
                                                   reason:@"APIKEY not set. You can get one at https://www.filepicker.io and insert it into your project's info.plist as 'Filepicker API Key'"
                                                 userInfo:nil];
        [apikeyException raise];
    }

    FPSourceListController *fpSourceListController = [FPSourceListController alloc];
    fpSourceListController.fpdelegate = self;
    fpSourceListController.imageDelegate = self;
    fpSourceListController.sourceNames = _sourceNames;
    fpSourceListController.dataTypes = _dataTypes;
    fpSourceListController.selectMultiple = _selectMultiple;
    fpSourceListController.maxFiles = _maxFiles;
    fpSourceListController.title = self.title;

    fpSourceListController = [fpSourceListController init];

    [self pushViewController:fpSourceListController animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.sourceNames = nil;
    self.dataTypes = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.hasStatusBar)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }


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

    const float ThumbnailSize = 115.0f;
    float scaleFactor = ThumbnailSize / fminf(imageToSave.size.height, imageToSave.size.width);
    float newHeight = imageToSave.size.height * scaleFactor;
    float newWidth = imageToSave.size.width * scaleFactor;

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [imageToSave drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if ([_fpdelegate respondsToSelector:@selector(FPPickerController:didPickMediaWithInfo:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *mediaInfo = @{
                @"FPPickerControllerThumbnailImage":thumbImage
            };

            [_fpdelegate FPPickerController:self
                       didPickMediaWithInfo:mediaInfo];
        });
    }

    FPMBProgressHUD *hud = [FPMBProgressHUD showHUDAddedTo:picker.view animated:YES];
    hud.labelText = @"Uploading...";
    hud.mode = FPMBProgressHUDModeDeterminate;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Picked Something From the Local Camera
        // nb: The camera roll is handled like a normal source as it is in FPLocalController
        NSLog(@"Picked something from local camera: %@ %@", info, kUTTypeImage);

        if ([info[@"UIImagePickerControllerMediaType"] isEqual:(NSString *)kUTTypeImage])
        {
            NSString *dataType = @"image/*";

            for (NSString *type in self.dataTypes)
            {
                if ([type isEqualToString:@"image/png"] || [type isEqualToString:@"image/jpeg"])
                {
                    dataType = type;
                }
            }

            NSLog(@"should upload: %@", _shouldUpload ? @"YES" : @"NO");

            FPUploadAssetSuccessWithLocalURLBlock successBlock = ^(id JSON,
                                                                   NSURL *localurl) {
                NSLog(@"JSON: %@", JSON);

                NSDictionary *data = JSON[@"data"][0];
                NSDictionary *output = @{
                    @"FPPickerControllerMediaType":info[@"UIImagePickerControllerMediaType"],
                    @"FPPickerControllerOriginalImage":imageToSave,
                    @"FPPickerControllerMediaURL":localurl,
                    @"FPPickerControllerRemoteURL":data[@"url"]
                };

                if (data[@"data"][@"key"])
                {
                    NSMutableDictionary *mutableOutput = [output mutableCopy];

                    mutableOutput[@"FPPickerControllerKey"] = data[@"data"][@"key"];
                    output = [mutableOutput copy];
                    mutableOutput = nil;
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [FPMBProgressHUD hideHUDForView:picker.view
                                           animated:YES];

                    [picker dismissViewControllerAnimated:NO
                                               completion: ^{
                        [_fpdelegate FPPickerController:self
                          didFinishPickingMediaWithInfo:output];
                    }];
                });
            };

            FPUploadAssetFailureWithLocalURLBlock failureBlock = ^(NSError *error,
                                                                   id JSON,
                                                                   NSURL *localurl) {
                NSDictionary *output = @{
                    @"FPPickerControllerMediaType":info[@"UIImagePickerControllerMediaType"],
                    @"FPPickerControllerOriginalImage":imageToSave,
                    @"FPPickerControllerMediaURL":localurl,
                    @"FPPickerControllerRemoteURL":@""
                };

                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"dispatched main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");

                    [FPMBProgressHUD hideHUDForView:self.view animated:YES];
                    [picker dismissViewControllerAnimated:NO
                                               completion: ^{
                        [_fpdelegate FPPickerController:self
                          didFinishPickingMediaWithInfo:output];
                    }];
                });
            };

            FPUploadAssetProgressBlock progressBlock = ^(float progress) {
                hud.progress = progress;
            };

            [FPLibrary uploadImage:imageToSave
                        ofMimetype:dataType
                       withOptions:info
                      shouldUpload:self.shouldUpload
                           success:successBlock
                           failure:failureBlock
                          progress:progressBlock];
        }
        else if ([info[@"UIImagePickerControllerMediaType"] isEqual:(NSString *)kUTTypeMovie])
        {
            NSURL *url = info[@"UIImagePickerControllerMediaURL"];

            FPUploadAssetSuccessWithLocalURLBlock successBlock = ^(id JSON,
                                                                   NSURL *localurl) {
                NSLog(@"JSON: %@", JSON);

                NSDictionary *output = @{
                    @"FPPickerControllerMediaType":info[@"UIImagePickerControllerMediaType"],
                    @"FPPickerControllerMediaURL":localurl,
                    @"FPPickerControllerRemoteURL":JSON[@"data"][0][@"url"],
                };

                dispatch_async(dispatch_get_main_queue(), ^{
                    [FPMBProgressHUD hideHUDForView:picker.view
                                           animated:YES];

                    [picker dismissViewControllerAnimated:NO
                                               completion: ^{
                        [_fpdelegate FPPickerController:self
                          didFinishPickingMediaWithInfo:output];
                    }];
                });
            };

            FPUploadAssetFailureWithLocalURLBlock failureBlock = ^(NSError *error,
                                                                   id JSON,
                                                                   NSURL *localurl) {
                NSLog(@"JSON: %@", JSON);

                NSDictionary *output = @{
                    @"FPPickerControllerMediaType":info[@"UIImagePickerControllerMediaType"],
                    @"FPPickerControllerMediaURL":localurl,
                    @"FPPickerControllerRemoteURL":@""
                };

                dispatch_async(dispatch_get_main_queue(), ^{
                    [FPMBProgressHUD hideHUDForView:self.view
                                           animated:YES];

                    [picker dismissViewControllerAnimated:NO
                                               completion: ^{
                        [_fpdelegate FPPickerController:self
                          didFinishPickingMediaWithInfo:output];
                    }];
                });
            };

            FPUploadAssetProgressBlock progressBlock = ^(float progress) {
                hud.progress = progress;
            };

            [FPLibrary uploadVideoURL:url
                          withOptions:info
                         shouldUpload:self.shouldUpload
                              success:successBlock
                              failure:failureBlock
                             progress:progressBlock];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error. We couldn't handle this file %@", info);
                NSLog(@"Type: %@", info[@"UIImagePickerControllerMediaType"]);

                [FPMBProgressHUD hideHUDForView:self.view
                                       animated:YES];

                [picker dismissViewControllerAnimated:NO
                                           completion: ^{
                    [_fpdelegate FPPickerControllerDidCancel:self];
                }];
            });
        }
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.hasStatusBar)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }

    // The user chose to cancel when using the camera.
    NSLog(@"Canceled something from local camera");

    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

#pragma mark FPSourcePickerDelegate Methods

- (void)FPSourceController:(FPSourceController *)picker didPickMediaWithInfo:(NSDictionary *)info
{
    if ([_fpdelegate respondsToSelector:@selector(FPPickerController:didPickMediaWithInfo:)])
    {
        [_fpdelegate FPPickerController:self
                   didPickMediaWithInfo:info];
    }
}

- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //The user chose a file from the cloud or camera roll.
    NSLog(@"Picked something from a source: %@", info);

    [_fpdelegate FPPickerController:self
      didFinishPickingMediaWithInfo:info];

    _fpdelegate = nil;
}

- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    //The user chose a file from the cloud or camera roll.
    NSLog(@"Picked multiple files from a source: %@", results);

    //It's optional, so check
    if ([_fpdelegate respondsToSelector:@selector(FPPickerController:didFinishPickingMultipleMediaWithResults:)])
    {
        [_fpdelegate FPPickerController:self
         didFinishPickingMultipleMediaWithResults:results];
    }

    _fpdelegate = nil;
}

- (void)FPSourceControllerDidCancel:(FPSourceController *)picker
{
    //The user chose to cancel when using the cloud or camera roll.
    NSLog(@"FP Canceled.");

    //It's optional, so check
    if ([_fpdelegate respondsToSelector:@selector(FPPickerControllerDidCancel:)])
    {
        [_fpdelegate FPPickerControllerDidCancel:self];
    }

    _fpdelegate = nil;
}

#pragma mark UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    return;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    return;
}

@end
