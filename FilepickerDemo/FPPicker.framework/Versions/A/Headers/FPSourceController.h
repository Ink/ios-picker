//
//  ServiceController.h
//  filepicker
//
//  Created by Liyan David Chang on 6/25/12.
//  Copyright (c) 2012 Filepicker.io, All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FP_PullRefreshTableViewController.h"
#import "FPAuthController.h"
#import "FPLibrary.h"

@interface FPSourceController : FP_PullRefreshTableViewController

@property (nonatomic, retain) NSMutableArray *contents;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *sourceType;
@property (nonatomic, retain) NSString *viewType;
@property (nonatomic, assign) id <FPSourcePickerDelegate> fpdelegate;
@property (nonatomic, retain) NSMutableDictionary *precaching;
@property (nonatomic, assign) BOOL shouldLoad;

- (void) fpLoadContents:(NSString *)loadpath;
- (void) objectSelectedAtIndex:(NSInteger) index;

@end
