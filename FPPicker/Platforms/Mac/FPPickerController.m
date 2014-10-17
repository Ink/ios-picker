//
//  FPPickerController.m
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPPickerController.h"
#import "FPInternalHeaders.h"
#import "FPDialogController.h"
#import "FPFileDownloadController.h"

@interface FPPickerController () <NSWindowDelegate,
                                  FPFileTransferControllerDelegate>

@property (nonatomic, weak) IBOutlet FPDialogController *dialogController;
@property (nonatomic, assign) NSModalSession modalSession;

@end

@implementation FPPickerController

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [[self.class alloc] initWithWindowNibName:@"FPPickerController"];

        self.shouldDownload = YES;
    }

    return self;
}

- (void)open
{
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];

    [NSApp runModalSession:self.modalSession];
}

#pragma mark - NSWindowController Methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.dialogController setupSourceListWithSourceNames:self.sourceNames
                                             andDataTypes:self.dataTypes];
}

#pragma mark - NSWindowDelegate Methods

- (void)windowWillClose:(NSNotification *)notification
{
    if (self.modalSession)
    {
        [NSApp endModalSession:self.modalSession];
    }
}

#pragma mark - FPFileTransferControllerDelegate Methods

- (void)FPFileTransferControllerDidFinish:(FPFileTransferController *)transferController
                                     info:(id)info
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPPickerController:didFinishPickingMultipleMediaWithResults:)])
    {
        [self.delegate FPPickerController:self
         didFinishPickingMultipleMediaWithResults:info];
    }
}

- (void)FPFileTransferControllerDidFail:(FPFileTransferController *)transferController
                                  error:(NSError *)error
{
    DLog(@"Error downloading: %@", error);
}

- (void)FPFileTransferControllerDidCancel:(FPFileTransferController *)transferController
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPPickerControllerDidCancel:)])
    {
        [self.delegate FPPickerControllerDidCancel:self];
    }
}

#pragma mark - Actions

- (IBAction)openFiles:(id)sender
{
    // Validate selection by looking for directories

    NSArray *selectedItems = [self.dialogController selectedItems];
    FPBaseSourceController *sourceController = [self.dialogController selectedSourceController];

    if (!selectedItems)
    {
        return;
    }

    for (NSDictionary *item in selectedItems)
    {
        if ([item[@"is_dir"] boolValue])
        {
            // Display alert with error

            NSError *error = [FPUtils errorWithCode:200
                              andLocalizedDescription:@"Selection must not contain any directories."];

            [FPUtils presentError:error
                  withMessageText:@"Selection error"];

            return;
        }
    }

    FPFileDownloadController *fileDownloadController = [[FPFileDownloadController alloc] initWithItems:selectedItems];

    fileDownloadController.delegate = self;
    fileDownloadController.sourceController = sourceController;
    fileDownloadController.shouldDownloadData = self.shouldDownload;

    [fileDownloadController process];

    [self.window close];
}

- (IBAction)close:(id)sender
{
    [self.dialogController cancelAllOperations];
    [self.window close];
}

@end
