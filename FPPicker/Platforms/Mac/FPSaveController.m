//
//  FPSaveController.m
//  FPPicker
//
//  Created by Ruben Nine on 15/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSaveController.h"
#import "FPDialogController.h"
#import "FPFileUploadController.h"
#import "FPRepresentedSource.h"
#import "FPMediaInfo.h"
#import "FPUtils.h"

@interface FPSaveController () <FPDialogControllerDelegate,
                                FPFileTransferControllerDelegate>

@property (nonatomic, strong) FPDialogController *dialogController;
@property (nonatomic, strong) FPFileUploadController *uploadController;

@end

@implementation FPSaveController

#pragma mark - Accessors

- (FPDialogController *)dialogController
{
    if (!_dialogController)
    {
        _dialogController = [[FPDialogController alloc] initWithWindowNibName:@"FPSaveController"];

        _dialogController.delegate = self;
    }

    return _dialogController;
}

#pragma mark - Public Methods

- (void)open
{
    [self.dialogController open];
}

#pragma mark - FPDialogControllerDelegate Methods

- (void)dialogControllerDidLoadWindow:(FPDialogController *)dialogController
{
    [self.dialogController setupDialogForSavingWithDefaultFileName:self.proposedFilename];

    [self.dialogController setupSourceListWithSourceNames:self.sourceNames
                                             andDataTypes:@[self.dataType]];
}

- (void)dialogControllerPressedActionButton:(FPDialogController *)dialogController
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
    else
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"Either data or dataURL must be present.)"];

        return;
    }

    [dialogController close];

    self.uploadController.delegate = self;

    [self.uploadController process];
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
        [self.delegate respondsToSelector:@selector(FPSaveController:didFinishSavingMediaWithInfo:)])
    {
        FPMediaInfo *mediaInfo = info;

        mediaInfo.source = self.dialogController.selectedRepresentedSource.source;
        mediaInfo.mediaURL = self.dataURL;
        mediaInfo.mediaType = [FPUtils UTIForMimetype:self.dataType];

        if (self.data)
        {
            mediaInfo.filesize = @(self.data.length);
        }
        else if (self.dataURL)
        {
            NSNumber *fileSizeValue = nil;
            NSError *fileSizeError = nil;

            [self.dataURL getResourceValue:&fileSizeValue
                                    forKey:NSURLFileSizeKey
                                     error:&fileSizeError];

            if (fileSizeValue)
            {
                mediaInfo.filesize = fileSizeValue;
            }
            else
            {
                DLog(@"Error getting size for URL %@: %@",
                     self.dataURL,
                     fileSizeError);
            }
        }

        [self.delegate FPSaveController:self
           didFinishSavingMediaWithInfo:mediaInfo];
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
        DLog(@"Upload was cancelled.");
    }
}

@end
