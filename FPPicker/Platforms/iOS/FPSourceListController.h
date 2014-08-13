//
//  FPSourceListController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPicker.h"
#import "FPInternalHeaders.h"

@interface FPSourceListController : UITableViewController <UINavigationBarDelegate>

@property (nonatomic, strong) NSArray *sourceNames;

@property (nonatomic, strong) NSMutableDictionary *sources;
@property (nonatomic, weak) id <FPSourcePickerDelegate> fpdelegate;
@property (nonatomic, weak) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> imageDelegate;

@property (nonatomic, strong) NSArray *dataTypes;
@property (nonatomic) BOOL selectMultiple;
@property (nonatomic) NSInteger maxFiles;

@end
