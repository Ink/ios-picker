//
//  ViewController.m
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "ViewController.h"

@import FPPickerMac;

@interface ViewController () <FPPickerDelegate,
                              FPSaveDelegate>

@property (nonatomic, strong) FPPickerController *pickerController;
@property (nonatomic, strong) FPSaveController *saveController;

@end

@implementation ViewController

#pragma mark - Accessors

- (FPPickerController *)pickerController
{
    if (!_pickerController)
    {
        _pickerController = [FPPickerController new];

        _pickerController.delegate = self;
    }

    return _pickerController;
}

- (FPSaveController *)saveController
{
    if (!_saveController)
    {
        _saveController = [FPSaveController new];

        _saveController.delegate = self;
    }

    return _saveController;
}

#pragma mark - Public Methods

- (IBAction)selectImageAction:(id)sender
{
    self.pickerController.shouldDownload = YES;

    self.pickerController.sourceNames = @[
        FPSourceDropbox,
        FPSourceFlickr,
        FPSourceImagesearch
                                        ];

    self.pickerController.dataTypes = @[
        @"image/*",
        @"video/quicktime"
                                      ];

    [self.pickerController open];
}

- (IBAction)saveImageAction:(id)sender
{
    self.saveController.sourceNames = @[
        FPSourceDropbox,
        FPSourceFlickr
                                      ];

    self.saveController.data = [NSData data];
    self.saveController.dataType = @"image/jpeg";
    self.saveController.proposedFilename = @"foobar.jpg";

    [self.saveController open];
}

#pragma mark - FPPickerDelegate Methods

- (void)                  FPPickerController:(FPPickerController *)pickerController
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

- (void)FPPickerControllerDidCancel:(FPPickerController *)pickerController
{
    NSLog(@"Picker was cancelled.");
}

#pragma mark - FPSaveDelegate Methods

- (void)        FPSaveController:(FPSaveController *)saveController
    didFinishSavingMediaWithInfo:(FPMediaInfo *)info
{
    NSLog(@"Saved media: %@", info);
}

- (void)FPSaveController:(FPSaveController *)saveController
                didError:(NSError *)error
{
    NSLog(@"Error saving media: %@", error);
}

- (void)FPSaveControllerDidCancel:(FPSaveController *)saveController
{
    NSLog(@"Saving was cancelled.");
}

@end
