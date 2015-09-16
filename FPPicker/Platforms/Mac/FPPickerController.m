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

@interface FPPickerController () <FPDialogControllerDelegate,
                                  FPFileTransferControllerDelegate>

@property (nonatomic, strong) FPDialogController *dialogController;

@end

@implementation FPPickerController

#pragma mark - Accessors

- (FPDialogController *)dialogController
{
    if (!_dialogController)
    {
        _dialogController = [[FPDialogController alloc] initWithWindowNibName:@"FPPickerController"];

        _dialogController.delegate = self;
    }

    return _dialogController;
}

- (void)setSourceNames:(NSArray *)sourceNames
{
    _sourceNames = sourceNames;

    if (self.dataTypes && self.sourceNames)
    {
        [self.dialogController setupSourceListWithSourceNames:self.sourceNames
                                                 andDataTypes:self.dataTypes];
    }
}

- (void)setDataTypes:(NSArray *)dataTypes
{
    _dataTypes = dataTypes;

    if (self.dataTypes && self.sourceNames)
    {
        [self.dialogController setupSourceListWithSourceNames:self.sourceNames
                                                 andDataTypes:self.dataTypes];
    }
}

#pragma mark - Public Methods

- (void)open
{
    [self.dialogController open];
}

#pragma mark - FPDialogControllerDelegate Methods

- (void)dialogControllerDidLoadWindow:(FPDialogController *)dialogController
{
    [self.dialogController setupDialogForOpening];

    [self.dialogController setupSourceListWithSourceNames:self.sourceNames
                                             andDataTypes:self.dataTypes];
}

- (void)dialogControllerPressedActionButton:(FPDialogController *)dialogController
{
    // Validate selection by ensuring it contains files but no directoreies

    NSArray *selectedItems = [dialogController selectedItems];

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
                            andLocalizedDescription         :@"Selection must not contain any directories."];

            [FPUtils presentError:error
                  withMessageText:@"Invalid selection"];

            return;
        }
    }

    [dialogController close];

    FPRepresentedSource *representedSource = [dialogController selectedRepresentedSource];

    FPFileDownloadController *fileDownloadController;

    fileDownloadController = [[FPFileDownloadController alloc] initWithItems:selectedItems
                                                        andRepresentedSource      :representedSource];

    fileDownloadController.delegate = self;

    [fileDownloadController process];
}

- (void)dialogControllerPressedCancelButton:(FPDialogController *)dialogController
{
    [dialogController close];
}

#pragma mark - FPFileTransferControllerDelegate Methods

- (void)FPFileTransferControllerDidFinish:(FPFileTransferController *)transferController
                                     info:(id)info
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(fpPickerController:didFinishPickingMultipleMediaWithResults:)])
    {
        [self.delegate fpPickerController:self
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
        [self.delegate respondsToSelector:@selector(fpPickerControllerDidCancel:)])
    {
        [self.delegate fpPickerControllerDidCancel:self];
    }
}

@end
