//
//  ViewController.m
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "ViewController.h"

@import FPPickerMac;

@interface ViewController () <FPPickerControllerDelegate,
                              FPSaveControllerDelegate>

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
        FPSourceGithub,
        FPSourceBox,
        FPSourceGoogleDrive,
        FPSourceGmail,
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
        FPSourceBox,
        FPSourceGoogleDrive,
        FPSourceSkydrive
                                      ];


    if (self.imageView.image)
    {
        CGImageRef CGImage = [self.imageView.image CGImageForProposedRect:nil
                                                                  context:nil
                                                                    hints:nil];
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:CGImage];

        NSData *bitmapData = [bitmapRep representationUsingType:NSJPEGFileType
                                                     properties:nil];

        self.saveController.data = bitmapData;
        self.saveController.dataType = @"image/jpeg";
        self.saveController.proposedFilename = @"default.jpg";

        [self.saveController open];
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Image missing"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"The image view must contain an image."];

        [alert runModal];
    }
}

#pragma mark - FPPickerControllerDelegate Methods

- (void)                  FPPickerController:(FPPickerController *)pickerController
    didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    for (FPMediaInfo *info in results)
    {
        NSLog(@"Got media: %@", info);

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

#pragma mark - FPSaveControllerDelegate Methods

- (void)        FPSaveController:(FPSaveController *)saveController
    didFinishSavingMediaWithInfo:(FPMediaInfo *)info
{
    NSLog(@"Saved media: %@", info);

    NSAlert *alert = [NSAlert alertWithMessageText:@"Image saved"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"The image was successfully saved!"];

    [alert runModal];
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
