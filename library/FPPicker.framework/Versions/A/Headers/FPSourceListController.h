//
//  TableViewController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPSearchController.h"
#import "FPLocalController.h"
#import "FPSource.h"

@interface FPSourceListController : UITableViewController <UIImagePickerControllerDelegate, UINavigationBarDelegate>

@property (nonatomic, strong) NSArray *sourceNames;

@property (nonatomic, strong) NSMutableDictionary *sources;
@property (nonatomic, assign) id <FPSourcePickerDelegate> fpdelegate;
@property (nonatomic, assign) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> imgdelagate;

@property (nonatomic, strong) NSArray *dataTypes;

@end
