//
//  TableViewController.h
//  filepicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io, All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPSearchController.h"
#import "FPLocalController.h"

@interface FPSourceListController : UITableViewController <UIImagePickerControllerDelegate, UINavigationBarDelegate>

@property (nonatomic, retain) NSArray *sourceNames;

@property (nonatomic, retain) NSMutableDictionary *sources;
@property (nonatomic, retain) id <FPSourcePickerDelegate> fpdelegate;
@property (nonatomic, retain) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> imgdelagate;

@end
