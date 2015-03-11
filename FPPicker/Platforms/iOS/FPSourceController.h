//
//  ServiceController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPInternalHeaders.h"

@interface FPSourceController : FPTableWithUploadButtonViewController

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) FPSource *source;
@property (nonatomic, strong) NSString *viewType;
@property (nonatomic, strong) NSString *nextPage;
@property (nonatomic, strong) UIActivityIndicatorView *nextPageSpinner;
@property (nonatomic, weak) id <FPSourceControllerDelegate> fpdelegate;


- (void)fpLoadContents:(NSString *)loadpath;

- (void)afterReload;

- (void)fileSelectedAtIndex:(NSInteger)index
                   forView:(UIView*)view
             withThumbnail:(UIImage *)thumbnail;

- (void)pushDirectoryControllerForPath:(NSString*)path;
@end
