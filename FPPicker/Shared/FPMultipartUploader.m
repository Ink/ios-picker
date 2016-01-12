//
//  FPMultipartUploader.m
//  FPPicker
//
//  Created by Ruben Nine on 25/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#define FPUploader_protected

#import "FPMultipartUploader.h"
#import "FPProgressTracker.h"
#import "FPUtils.h"
#import "FPSession+ConvenienceMethods.h"

@interface FPMultipartUploader ()

@property (nonatomic, strong) FPProgressTracker *progressTracker;
@property (nonatomic, strong) NSFileHandle *inputFileHandle;
@property (nonatomic, strong) NSString *uploadID;
@property (nonatomic, assign) int totalChunks;
@property (nonatomic, assign) int sentChunks;
@property (nonatomic, assign) size_t fileSize;
@property (nonatomic, assign) int progressIndex;

@end

@implementation FPMultipartUploader

/**
   This semaphore will allow us to perform multiple file uploads in a synchronized fashion.
   One of the advantages of this is that we will be able to monitor total uploaded files in
   the order the user expects them.

   @note This does not affect chunk uploads. These will continue to be uploaded in parallel.
 */
+ (dispatch_semaphore_t)lock_semaphore
{
    static dispatch_semaphore_t _lock_semaphore;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _lock_semaphore = dispatch_semaphore_create(1);
    });

    return _lock_semaphore;
}

- (void)doUpload
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self uploadWithRetries:fpNumRetries];
    });
}

#pragma mark - Private Methods

- (void)uploadWithRetries:(int)retries
{
    dispatch_semaphore_wait([self.class lock_semaphore], DISPATCH_TIME_FOREVER);

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        DLog(@"Response: %@", responseObject);

        // Set progress to 1/3 of the total

        for (int c = 0; c < self.totalChunks; c++)
        {
            [self updateProgressAtIndex:self.progressIndex++
                              withValue:1.0f];
        }

        self.uploadID = responseObject[@"data"][@"id"];

        [self uploadChunks];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (retries <= 1)
        {
            [self finishWithError:error];
        }
        else
        {
            dispatch_semaphore_signal([self.class lock_semaphore]);

            [self uploadWithRetries:retries - 1];
        }
    };

    NSDictionary *params = @{
        @"name":self.filename,
        @"filesize":@(self.fileSize),
        @"js_session":self.js_sessionString
    };

    [[FPAPIClient sharedClient] POST:@"/api/upload/multipart/start/"
                          parameters:params
                 usingOperationQueue:self.operationQueue
                             success:successOperationBlock
                             failure:failureOperationBlock];
}

- (void)setup
{
    [super setup];

    self.fileSize = [FPUtils fileSizeForLocalURL:self.localURL];

    NSAssert(self.fileSize > 0, @"File %@ is empty", self.localURL);

    self.inputFileHandle = [NSFileHandle fileHandleForReadingAtPath:self.localURL.path];
    self.totalChunks = (int)ceilf(1.0f * self.fileSize / fpMaxChunkSize);
    self.sentChunks = 0;
    self.progressIndex = 0;

    /*
       Our progress tracker will measure progress of the sum of:

       1. multipart start request
       2. each chunk uploaded
       3. multipart end request

       Each step will represent 1/3 of the total.

       In our case, this means each part will represent exactly self.totalChunks.
       This way, we give equal weight to each step.
     */

    self.progressTracker = [[FPProgressTracker alloc] initWithObjectCount:self.totalChunks * 3];
}

- (void)uploadChunks
{
    DLog(@"Filesize: %lu chunks: %d", (unsigned long)self.fileSize, (int)self.totalChunks);

    NSString *escapedSessionString = [FPUtils urlEncodeString:self.js_sessionString];
    uint8_t *chunkBuffer = malloc(sizeof(uint8_t) * fpMaxChunkSize);

    /* send the chunks */
    for (int i = 0; i < self.totalChunks; i++)
    {
        DLog(@"Sending slice #%d", i);

        NSString *uploadPath;

        uploadPath = [NSString stringWithFormat:@"/api/upload/multipart/upload/?id=%@&index=%d&js_session=%@",
                      self.uploadID,
                      i,
                      escapedSessionString];

        NSData *readData = [self.inputFileHandle readDataOfLength:fpMaxChunkSize];

        if (readData.length > 0)
        {
            [self uploadChunkWithDataSlice:readData
                                uploadPath:uploadPath
                                     index:i
                                     retry:fpNumRetries];
        }
        else
        {
            NSString *localizedErrorDescription = [NSString stringWithFormat:@"Unable to read from file handle %@", self.inputFileHandle];

            NSError *error = [FPUtils errorWithCode:200
                            andLocalizedDescription         :localizedErrorDescription];

            [self finishWithError:error];
            break;
        }
    }

    free(chunkBuffer);
}

- (void)uploadChunkWithDataSlice:(NSData *)dataSlice
                      uploadPath:(NSString *)uploadPath
                           index:(int)index
                           retry:(int)retryTimes
{
    AFConstructingBodyBlock constructingBodyBlock = ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:dataSlice
                                    name:@"fileUpload"
                                fileName:self.filename
                                mimeType:self.mimetype];
    };

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        // Add one more processed chunk to progress bar
        // Once all chunks complete, 2/3 out of the total will be complete

        self.progressIndex++;

        [self updateProgressAtIndex:self.progressIndex
                          withValue:1.0f];

        self.sentChunks++;

        DLog(@"Send %d: %@ (sent: %d)", index, responseObject, self.sentChunks);

        if (self.sentChunks == self.totalChunks)
        {
            [self.inputFileHandle closeFile];
            [self endMultipartUploadWithRetries:fpNumRetries];
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (retryTimes <= 1)
        {
            [self finishWithError:error];
        }
        else
        {
            [self uploadChunkWithDataSlice:dataSlice
                                uploadPath:uploadPath
                                     index:index
                                     retry:retryTimes - 1];
        }
    };

    AFHTTPRequestOperation *operation = [[FPAPIClient sharedClient] POST:uploadPath
                                                              parameters:nil
                                               constructingBodyWithBlock:constructingBodyBlock
                                                     usingOperationQueue:self.operationQueue
                                                                 success:successOperationBlock
                                                                 failure:failureOperationBlock];

    [operation setUploadProgressBlock: ^(NSUInteger bytesWritten,
                                         long long totalBytesWritten,
                                         long long totalBytesExpectedToWrite) {
        if (totalBytesExpectedToWrite > 0)
        {
            float progress = (1.0f * totalBytesWritten) / totalBytesExpectedToWrite;

            [self updateProgressAtIndex:self.progressIndex + index
                              withValue:progress];
        }
    }];
}

- (void)endMultipartUploadWithRetries:(int)retries
{
    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        // Set progress to 3/3 by filling the last 1/3

        for (int c = 0; c < self.totalChunks; c++)
        {
            [self updateProgressAtIndex:self.progressIndex++
                              withValue:1.0f];
        }

        if (self.successBlock)
        {
            self.successBlock(responseObject);
        }

        self.hasFinished = YES;

        dispatch_semaphore_signal([self.class lock_semaphore]);
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (retries <= 1)
        {
            [self finishWithError:error];
        }
        else
        {
            [self endMultipartUploadWithRetries:retries - 1];
        }
    };

    NSDictionary *params = @{
        @"id":self.uploadID,
        @"total":@(self.totalChunks),
        @"js_session":self.js_sessionString
    };

    [[FPAPIClient sharedClient] POST:@"/api/upload/multipart/end/"
                          parameters:params
                 usingOperationQueue:self.operationQueue
                             success:successOperationBlock
                             failure:failureOperationBlock];
}

- (void)finishWithError:(NSError *)error
{
    if (self.failureBlock)
    {
        self.failureBlock(error, nil);
    }

    dispatch_semaphore_signal([self.class lock_semaphore]);
}

- (void)updateProgressAtIndex:(int)index
                    withValue:(float)value
{
    if (self.progressBlock)
    {
        float overallProgress = [self.progressTracker setProgress:value
                                                           forKey:@(index)];
        self.progressBlock(overallProgress);
    }
}

@end
