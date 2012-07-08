//
//  NavigationController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FPExternalHeaders.h"

@interface FPPickerController : UINavigationController <UIImagePickerControllerDelegate, FPSourcePickerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) id <FPPickerDelegate> fpdelegate;
@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSArray *dataTypes;

@end
