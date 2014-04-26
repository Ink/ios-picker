//
//  ViewController.h
//  FilepickerDemo
//
//  Created by Liyan David Chang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FPPicker/FPPicker.h>

@interface ViewController : UIViewController <FPPickerDelegate, UIPopoverControllerDelegate, FPSaveDelegate> {
    IBOutlet UIImageView *imageView;
    UIPopoverController *popoverController;
}
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIPopoverController *popoverController;


@end
