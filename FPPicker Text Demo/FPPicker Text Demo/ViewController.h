//
//  ViewController.h
//  FPPicker Text Demo
//
//  Created by Ruben Nine on 13/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FPPicker/FPPicker.h>

@interface ViewController : UIViewController <UITextViewDelegate, FPPickerDelegate, FPSaveDelegate>

@property (nonatomic, strong) IBOutlet UITextView *textView;

@end
