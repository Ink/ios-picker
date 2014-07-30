//
//  NavigationController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FPExternalHeaders.h"

@interface FPPickerController : UINavigationController <UIImagePickerControllerDelegate,
                                                        FPSourcePickerDelegate,
                                                        UINavigationControllerDelegate>

@property (nonatomic, weak) id <FPPickerDelegate> fpdelegate;
@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSArray *dataTypes;

// imagepicker properties

@property (nonatomic, assign) BOOL allowsEditing;
@property (nonatomic, assign) BOOL selectMultiple;
@property (nonatomic, assign) NSInteger maxFiles;

@property (nonatomic, assign) UIImagePickerControllerQualityType videoQuality;
@property (nonatomic, assign) NSTimeInterval videoMaximumDuration;
@property (nonatomic, assign) BOOL showsCameraControls;
@property (nonatomic, strong) UIView *cameraOverlayView;
@property (nonatomic, assign) CGAffineTransform cameraViewTransform;

@property (nonatomic, assign) UIImagePickerControllerCameraDevice cameraDevice;
@property (nonatomic, assign) UIImagePickerControllerCameraFlashMode cameraFlashMode;

@property (nonatomic, assign) BOOL shouldUpload;
@property (nonatomic, assign) BOOL shouldDownload;

@end
