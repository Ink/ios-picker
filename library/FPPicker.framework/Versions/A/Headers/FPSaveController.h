//
//  FPSaveController.h
//  FPPicker
//
//  Created by Liyan David Chang on 7/7/12.
//  Copyright (c) 2012 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FPExternalHeaders.h"

@interface FPSaveController : UINavigationController <FPSourcePickerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) id <FPSaveDelegate> fpdelegate;
@property (nonatomic, strong) NSArray *sourceNames;

@property (nonatomic, strong) NSData *data;
@property (nonatomic) NSString *dataType;

- (void) saveFileName:(NSString *)filename To:(NSString *)path;

@end
