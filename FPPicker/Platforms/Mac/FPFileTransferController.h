//
//  FPFileTransferWindowController.h
//  FPPicker
//
//  Created by Ruben on 10/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPFileTransferController;

@protocol FPFileTransferControllerDelegate <NSObject>

- (void)FPFileTransferControllerDidFinish:(FPFileTransferController *)transferController info:(id)info;
- (void)FPFileTransferControllerDidCancel:(FPFileTransferController *)transferController;
- (void)FPFileTransferControllerDidFail:(FPFileTransferController *)transferController error:(NSError *)error;

@end

@interface FPFileTransferController : NSWindowController

@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, strong) IBOutlet NSTextField *descriptionTextField;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, weak) id <FPFileTransferControllerDelegate> delegate;

- (void)process;
- (IBAction)cancel:(id)sender;

@end
