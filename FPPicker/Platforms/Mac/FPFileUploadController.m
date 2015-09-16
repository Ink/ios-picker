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

    [self validateArguments];

    // Call super

    [super process];

    // Callbacks

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressIndicator stopAnimation:self];
            [self.window close];
        });

        if (self.delegate)
        {
            FPMediaInfo *mediaInfo = [FPMediaInfo new];

            mediaInfo.filename = JSON[@"filename"];
            mediaInfo.remoteURL = JSON[@"url"];

            [self.delegate FPFileTransferControllerDidFinish:self
                                                        info:mediaInfo];
        }
        else
        {
            DLog(@"Upload succeeded with response: %@", JSON);
        }
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error,
                                               id JSON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressIndicator stopAnimation:self];
            [self.window close];
        });

        if (self.delegate)
        {
            [self.delegate FPFileTransferControllerDidFail:self
                                                     error:error];
        }
        else
        {
            DLog(@"Error saving %@, %@", error, JSON);
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
             usingOperationQueue:self.operationQueue
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
          usingOperationQueue:self.operationQueue
                      success:successBlock
                      failure:failureBlock
                     progress:progressBlock];
    }
}

#pragma mark - Private Methods

- (void)validateArguments
{
    if (!self.filename)
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"filename must be present."];
    }

    if (!self.targetPath)
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"targetPath must be present."];
    }

    if (!self.mimetype)
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"mimetype must be present."];
    }

    if (!self.data &
        !self.dataURL)
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"Either data or dataURL must be present."];
    }
}

@end
