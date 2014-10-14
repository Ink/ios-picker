//
//  ViewController.h
//  FPPicker iOS Demo
//
//  Created by Ruben Nine on 13/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIPopoverController *myPopoverController;

@end
