//
//  ViewController.h
//  FPPicker Integration Tests
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Cloudtop Inc.). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FPPicker/FPPicker.h>

extern NSString * const kSelectImageButtonAccesibilityLabel;
extern NSString * const kSaveImageButtonAccesibilityLabel;

@interface ViewController : UIViewController <FPPickerDelegate, UIPopoverControllerDelegate, FPSaveDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *selectImageButton;
@property (nonatomic, strong) IBOutlet UIButton *saveImageButton;

@property (nonatomic, strong) UIPopoverController *myPopoverController;

@end
