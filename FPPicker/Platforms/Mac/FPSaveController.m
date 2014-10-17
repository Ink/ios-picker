//
//  FPSaveController.m
//  FPPicker
//
//  Created by Ruben Nine on 15/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSaveController.h"
#import "FPInternalHeaders.h"
#import "FPDialogController.h"
#import "FPFileUploadController.h"

@interface FPSaveController  () <NSWindowDelegate,
                                 FPFileTransferControllerDelegate>

@property (nonatomic, weak) IBOutlet FPDialogController *dialogController;
@property (nonatomic, assign) NSModalSession modalSession;
@property (nonatomic, strong) FPFileUploadController *uploadController;

@end

@implementation FPSaveController

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [[self.class alloc] initWithWindowNibName:@"FPSaveController"];
    }

    return self;
}

- (void)open
{
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];

    [NSApp runModalSession:self.modalSession];
}

#pragma mark - Actions

- (IBAction)saveFile:(id)sender
{
    NSString *filename = [self.dialogController filenameFromSaveTextField];
    NSString *path = [self.dialogController currentPath];

    if (self.data)
    {
        self.uploadController = [[FPFileUploadController alloc] initWithData:self.data
                                                                    filename:filename
                                                                  targetPath:path
                                                                 andMimetype:self.dataType];
    }
    else if (self.dataURL)
    {
        self.uploadController = [[FPFileUploadController alloc] initWithDataURL:self.dataURL
                                                                       filename:filename
                                                                     targetPath:path
                                                                    andMimetype:self.dataType];
    }

    if (!self.uploadController)
    {
        DLog(@"No upload controller was intanstiated.");

        return;
    }

    self.uploadController.delegate = self;

    [self.uploadController process];


    {
        [self.window close];
    }
}

- (IBAction)close:(id)sender
{
    [self.dialogController cancelAllOperations];
    [self.window close];
}

#pragma mark - FPFileTransferControllerDelegate Methods

- (void)FPFileTransferControllerDidFinish:(FPFileTransferController *)transferController
                                     info:(id)info
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPSaveController:didFinishSavingMediaWithInfo:)])
    {
        [self.delegate FPSaveController:self
           didFinishSavingMediaWithInfo:info];
    }
    else
    {
        DLog(@"Upload finished: %@", info);
    }
}

- (void)FPFileTransferControllerDidFail:(FPFileTransferController *)transferController
                                  error:(NSError *)error
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPSaveController:didError:)])
    {
        [self.delegate FPSaveController:self
                               didError:error];
    }
    else
    {
        DLog(@"Upload failed: %@", error);
    }
}

- (void)FPFileTransferControllerDidCancel:(FPFileTransferController *)transferController
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPSaveControllerDidCancel:)])
    {
        [self.delegate FPSaveControllerDidCancel:self];
    }
    else
    {
        DLog(@"Upload was cancelled");
    }
}

#pragma mark - NSWindowDelegate Methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.dialogController setupDialogForSavingWithDefaultFileName:self.proposedFilename];

    [self.dialogController setupSourceListWithSourceNames:self.sourceNames
                                             andDataTypes:@[self.dataType]];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (self.modalSession)
    {
        [NSApp endModalSession:self.modalSession];
    }
}

@end
