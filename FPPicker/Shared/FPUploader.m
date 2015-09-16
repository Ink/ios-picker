//
//  FPUploader.m
//  FPPicker
//
//  Created by Ruben Nine on 16/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#define FPUploader_protected

#import "FPUploader.h"
#import "FPSession+ConvenienceMethods.h"

@interface FPUploader ()

@property (readwrite) NSOperationQueue *operationQueue;

@end

@implementation FPUploader

- (instancetype)initWithLocalURL:(NSURL *)localURL
                        filename:(NSString *)filename
                        mimetype:(NSString *)mimetype
               andOperationQueue:(NSOperationQueue *)operationQueue
{
    self = [super init];

    if (self)
    {
        NSAssert(localURL, @"LocalURL must be provided");
        NSAssert(mimetype, @"Mimetype must be provided");

        self.operationQueue = operationQueue;
        self.localURL = localURL;
        self.filename = filename;
        self.mimetype = mimetype;

        if (!self.filename)
        {
            self.filename = @"filename";
        }

        [self setup];
    }

    return self;
}

- (void)upload
{
    if (!self.hasFinished)
    {
        [self doUpload];
    }
    else
    {
        DLog(@"%@ already finished uploading.", self.filename);
    }
}

#pragma mark - Protected

- (void)setup
{
    FPSession *fpSession = [FPSession sessionForFileUploads];

    self.js_sessionString = [fpSession JSONSessionString];
    self.hasFinished = NO;
}

- (void)doUpload
{
    NSAssert(NO, @"This method must be implemented by subclasses.");
}

#pragma mark - Accessors

- (FPUploadAssetSuccessBlock)successBlock
{
    if (!_successBlock)
    {
        _successBlock = ^(id JSON) {
            DLog(@"Upload succeeded with response: %@", JSON);
        };
    }

    return _successBlock;
}

- (FPUploadAssetFailureBlock)failureBlock
{
    if (!_failureBlock)
    {
        _failureBlock = ^(NSError *error, id JSON) {
            DLog(@"FAILURE %@ %@", error, JSON);

            assert(false);
        };
    }

    return _failureBlock;
}

@end
