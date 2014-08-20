//
//  ViewController.m
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "ViewController.h"
#import <FPPickerMac/FPPicker.h>

@interface ViewController ()

@property (nonatomic, strong) FPPickerController *pickerController;

@end

@implementation ViewController

- (FPPickerController *)pickerController
{
    if (!_pickerController)
    {
        _pickerController = [FPPickerController new];
    }

    return _pickerController;
}

- (IBAction)selectImageAction:(id)sender
{
    [self.pickerController open];
}

- (IBAction)saveImageAction:(id)sender
{
}

@end
