//
//  ViewController.h
//  FPPicker Demo
//
//  Created by Ruben Nine on 13/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FPPicker/FPPicker.h>

@interface ViewController : UIViewController <FPPickerDelegate, UIPopoverControllerDelegate, FPSaveDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIPopoverController *myPopoverController;

@end
