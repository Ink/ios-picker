//
//  FPFileUploadController.m
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPFileUploadController.h"
#import "FPProgressTracker.h"
#import "FPLibrary.h"
#import "FPMediaInfo.h"

@interface FPFileTransferController ()

@property (readonly, assign) BOOL wasProcessCancelled;

- (IBAction)cancel:(id)sender;

@end

@interface FPFileUploadController ()

@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *targetPath;
@property (nonatomic, strong) NSString *mimetype;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *dataURL;

@end

@implementation FPFileUploadController

- (instancetype)initWithData:(NSData *)data
                    filename:(NSString *)filename
                  targetPath:(NSString *)path
                 andMimetype:(NSString *)mimetype
{
    self = [super init];

    if (self)
    {
        self.filename = filename;
        self.targetPath = path;
        self.data = data;
        self.mimetype = mimetype;
    }

    return self;
}

- (instancetype)initWithDataURL:(NSURL *)dataURL
                       filename:(NSString *)filename
                     targetPath:(NSString *)path
                    andMimetype:(NSString *)mimetype
{
    self = [super init];

    if (self)
    {
        self.filename = filename;
        self.targetPath = path;
        self.dataURL = dataURL;
        self.mimetype = mimetype;
    }

    return self;
}

- (void)process
{
    __block BOOL hasStarted = NO;

    // Validate arguments

    if (![self validateArguments])
    {
        return;
    }

    // Call super

    [super process];

    // Callbacks

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        DLog(@"Upload returned: %@", JSON);

        [self.progressIndicator stopAnimation:self];
        [self.window close];

        if (self.wasProcessCancelled)
        {
            if (self.delegate)
            {
                [self.delegate FPFileTransferControllerDidCancel:self];
            }
        }
        else
        {
            if (self.delegate)
            {
                FPMediaInfo *mediaInfo = [FPMediaInfo new];

                mediaInfo.filename = JSON[@"filename"];
                mediaInfo.remoteURL = JSON[@"url"];

                [self.delegate FPFileTransferControllerDidFinish:self
                                                            info:mediaInfo];
            }
        }
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error,
                                               id JSON) {
        DLog(@"Error saving %@, %@", error, JSON);

        [self.progressIndicator stopAnimation:self];
        [self.window close];

        if (self.delegate)
        {
            [self.delegate FPFileTransferControllerDidFail:self
                                                     error:error];
        }
    };

    FPUploadAssetProgressBlock progressBlock = ^(float progress) {
        if (!hasStarted)
        {
            hasStarted = YES;
            self.descriptionTextField.stringValue = @"Uploading 1 of 1 files";

            [self.progressIndicator setIndeterminate:NO];
        }

        self.progressIndicator.doubleValue = progress;
    };

    self.descriptionTextField.stringValue = @"About to start uploading file";

    [self.progressIndicator startAnimation:self];

    if (self.dataURL)
    {
        [FPLibrary uploadDataURL:self.dataURL
                           named:self.filename
                          toPath:self.targetPath
                      ofMimetype:self.mimetype
                     withOptions:nil
                         success:successBlock
                         failure:failureBlock
                        progress:progressBlock];
    }
    else
    {
        [FPLibrary uploadData:self.data
                        named:self.filename
                       toPath:self.targetPath
                   ofMimetype:self.mimetype
                  withOptions:nil
                      success:successBlock
                      failure:failureBlock
                     progress:progressBlock];
    }
}

#pragma mark - Private Methods

- (BOOL)validateArguments
{
    BOOL valid = YES;

    if (!self.filename)
    {
        DLog(@"No filename given.");

        valid = NO;
    }

    if (!self.targetPath)
    {
        DLog(@"No target path given.");

        valid = NO;
    }

    if (!self.mimetype)
    {
        DLog(@"No mimetype given.");

        valid = NO;
    }

    if (!self.data &
        !self.dataURL)
    {
        DLog(@"Either data or dataURL must be present.");

        valid = NO;
    }

    return valid;
}

@end
