//
//  ViewController.h
//  FilepickerDemoText
//
//  Created by Liyan David Chang on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FPPicker/FPPicker.h>

@interface ViewController : UIViewController <UITextViewDelegate, FPPickerDelegate, FPSaveDelegate>

@property (nonatomic, strong) IBOutlet UITextView *textView;

@end
