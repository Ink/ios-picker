//
//  FPSaveController.h
//  FPPicker
//
//  Created by Liyan David Chang on 7/7/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPExternalHeaders.h"

@class FPTheme;

@interface FPSaveController : UINavigationController

@property (nonatomic, weak) id <FPSaveControllerDelegate> fpdelegate;
@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) FPTheme *theme;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *dataurl;

@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, strong) NSString *dataExtension;

@property (nonatomic, strong) NSString *proposedFilename;

- (void)saveFileName:(NSString *)filename To:(NSString *)path;
- (void)saveFileLocally;

- (NSString *)getExtensionString;


@end
