//
//  FPSaveController.h
//  FPPicker
//
//  Created by Ruben Nine on 15/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPExternalHeaders.h"
#import "FPPickerController.h"

@interface FPSaveController : NSWindowController

@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *dataURL;
@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, strong) NSString *proposedFilename;
@property (nonatomic, weak) id<FPSaveDelegate> delegate;

- (void)open;

@end
