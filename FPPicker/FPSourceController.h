//
//  ServiceController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FPPicker.h"
#import "FPInternalHeaders.h"

@interface FPSourceController : FP_PullRefreshTableViewController

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) FPSource *sourceType;
@property (nonatomic, strong) NSString *viewType;
@property (nonatomic, strong) NSString *nextPage;
@property (nonatomic, strong) UIActivityIndicatorView *nextPageSpinner;

@property (nonatomic, strong) id <FPSourcePickerDelegate> fpdelegate;
@property (nonatomic, strong) NSMutableDictionary *precacheOperations;

- (void) fpLoadContents:(NSString *)loadpath;
- (void) objectSelectedAtIndex:(NSInteger) index;
- (void) afterReload;

@end
