//
//  NavigationController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPExternalHeaders.h"

@class FPTheme;

@interface FPPickerController : UINavigationController

@property (nonatomic, weak) id <FPPickerControllerDelegate> fpdelegate;
@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSArray *dataTypes;
@property (nonatomic, strong) FPTheme *theme;

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

/*!
   Disables the front camera live preview mirroring (experimental)
   Side-effect: overrides the existing `cameraViewTransform`.
 */
@property (nonatomic, assign) BOOL disableFrontCameraLivePreviewMirroring;

@end
