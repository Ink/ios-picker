//
//  FPSourceListController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPExternalHeaders.h"

@protocol FPSourceControllerDelegate;

@interface FPSourceListController : UITableViewController <UINavigationBarDelegate,
                                                           UITableViewDataSource,
                                                           UITableViewDelegate>

@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSDictionary *sources;

@property (nonatomic, weak) id <FPSourceControllerDelegate> fpdelegate;
@property (nonatomic, weak) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> imageDelegate;

@property (nonatomic, strong) NSArray *dataTypes;
@property (nonatomic) BOOL selectMultiple;
@property (nonatomic) NSInteger maxFiles;

@end
