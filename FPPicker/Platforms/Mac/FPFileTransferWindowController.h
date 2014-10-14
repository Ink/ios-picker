//
//  FPFileTransferWindowController.h
//  FPPicker
//
//  Created by Ruben on 10/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPFileTransferWindowController;
@class FPBaseSourceController;

@protocol FPFileTransferWindowControllerDelegate <NSObject>

- (BOOL)FPFileTransferControllerShouldDownload:(FPFileTransferWindowController *)fileTransferWindowController;
- (BOOL)FPFileTransferControllerShouldUpload:(FPFileTransferWindowController *)fileTransferWindowController;

- (void)FPFileTransferController:(FPFileTransferWindowController *)fileTransferWindowController
       didFinishDownloadingItems:(NSArray *)items;

@end

@interface FPFileTransferWindowController : NSWindowController

@property (nonatomic, strong) IBOutlet NSTextField *descriptionTextField;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, weak) FPBaseSourceController *sourceController;
@property (nonatomic, weak) id<FPFileTransferWindowControllerDelegate>delegate;

- (void)enqueueItems:(NSArray *)items;
- (void)process;

@end
