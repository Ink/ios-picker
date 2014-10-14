//
//  ViewController.m
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "ViewController.h"

@import FPPickerMac;

@interface ViewController () <FPPickerDelegate>

@property (nonatomic, strong) FPPickerController *pickerController;

@end

@implementation ViewController

#pragma mark - Accessors

- (FPPickerController *)pickerController
{
    if (!_pickerController)
    {
        _pickerController = [FPPickerController new];

        _pickerController.delegate = self;
        _pickerController.shouldDownload = YES;
        _pickerController.shouldUpload = YES;

        _pickerController.sourceNames = @[
            FPSourceDropbox,
            FPSourceFlickr,
            FPSourceImagesearch
                                        ];

        _pickerController.dataTypes = @[
            @"image/*",
            @"video/quicktime"
                                      ];
    }

    return _pickerController;
}

#pragma mark - Public Methods

- (IBAction)selectImageAction:(id)sender
{
    [self.pickerController open];
}

- (IBAction)saveImageAction:(id)sender
{
}

#pragma mark - FPPickerDelegate Methods

- (void)                  FPPickerController:(FPPickerController *)picker
    didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    for (FPMediaInfo *info in results)
    {
        if (info.containsImageAtMediaURL)
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:info.mediaURL];

            self.imageView.image = image;
        }
    }
}

@end
