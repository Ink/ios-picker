//
//  FPImagePickerController.m
//  FPPicker
//
//  Created by Ruben on 9/18/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPImagePickerController.h"
@import AVFoundation.AVCaptureSession;

@interface FPImagePickerController ()

@property (nonatomic, assign) BOOL isRegisteredForNotifications;

@end

@implementation FPImagePickerController

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.isRegisteredForNotifications = NO;
        self.disableFrontCameraLivePreviewMirroring = NO;
    }

    return self;
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

- (void)setDisableFrontCameraLivePreviewMirroring:(BOOL)disableFrontCameraMirroring
{
    _disableFrontCameraLivePreviewMirroring = disableFrontCameraMirroring;

    if (disableFrontCameraMirroring)
    {
        if (self.isRegisteredForNotifications)
        {
            [self unregisterForNotifications];
        }

        [self registerForNotifications];
    }
    else
    {
        [self unregisterForNotifications];
    }
}

#pragma mark - Private Methods

- (void)orientationChanged:(NSNotification *)notification
{
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        CGFloat sx = -1;

        if (UIDeviceOrientationIsLandscape(orientation))
        {
            sx = 1;
        }

        CGFloat sy = -sx;

        self.cameraViewTransform = CGAffineTransformIdentity;
        self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, sx, sy);
    }
}

- (void)cameraChanged:(NSNotification *)notification
{
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        self.cameraViewTransform = CGAffineTransformIdentity;
        self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, -1, 1);
    }
    else
    {
        self.cameraViewTransform = CGAffineTransformIdentity;
    }
}

- (void)registerForNotifications
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraChanged:)
                                                 name:AVCaptureSessionDidStartRunningNotification
                                               object:nil];

    self.isRegisteredForNotifications = YES;
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVCaptureSessionDidStartRunningNotification
                                                  object:nil];

    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    self.isRegisteredForNotifications = NO;
}

@end
