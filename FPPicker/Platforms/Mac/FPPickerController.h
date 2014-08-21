//
//  FPPickerController.h
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPRemoteSourceController;
@class FPSourceListController;

@interface FPPickerController : NSViewController <NSWindowDelegate>

@property (nonatomic, weak) IBOutlet FPRemoteSourceController *remoteSourceController;
@property (nonatomic, weak) IBOutlet FPSourceListController *sourceListController;
@property (nonatomic, weak) IBOutlet NSImageView *fpLogo;
@property (nonatomic, weak) NSWindow *window;

- (void)open;

@end
