//
//  FPLocalAlbumController.h
//  FPPicker
//
//  Created by Liyan David Chang on 4/17/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPInternalHeaders.h"

@interface FPLocalAlbumController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, weak) id <FPSourcePickerDelegate> fpdelegate;
@property (nonatomic, strong) FPSource *source;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL selectMultiple;
@property (nonatomic) NSInteger maxFiles;

@end
