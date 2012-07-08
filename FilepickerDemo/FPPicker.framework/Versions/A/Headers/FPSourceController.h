//
//  ServiceController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FP_PullRefreshTableViewController.h"
#import "FPAuthController.h"
#import "FPLibrary.h"
#import "FPSource.h"
#import "FPConstants.h"

@interface FPSourceController : FP_PullRefreshTableViewController

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) FPSource *sourceType;
@property (nonatomic, strong) NSString *viewType;
@property (nonatomic, assign) id <FPSourcePickerDelegate> fpdelegate;
//TODO rename
@property (nonatomic, strong) NSMutableDictionary *precacheOperations;
@property (nonatomic, assign) BOOL shouldLoad;

- (void) fpLoadContents:(NSString *)loadpath;
- (void) objectSelectedAtIndex:(NSInteger) index;

@end
