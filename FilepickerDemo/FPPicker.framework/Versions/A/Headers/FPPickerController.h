//
//  NavigationController.h
//  filepicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io, All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FPSourceListController.h"

@interface FPPickerController : UINavigationController <UIImagePickerControllerDelegate, FPSourcePickerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) id <FPPickerDelegate> fpdelegate;
@property (nonatomic, retain) NSArray *sourceNames;

@end
