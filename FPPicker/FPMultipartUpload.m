//
//  FPMultipartUpload.m
//  FPPicker
//
//  Created by Ruben Nine on 25/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPMultipartUpload.h"
#import "FPProgressTracker.h"
#import "FPUtils.h"

@interface FPMultipartUpload ()

@property (nonatomic, assign) BOOL hasFinished;
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *mimetype;
@property (nonatomic, strong) FPProgressTracker *progressTracker;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSString *uploadID;
@property (nonatomic, strong) NSString *js_sessionString;
@property (nonatomic, assign) int totalChunks;
@property (nonatomic, assign) int sentChunks;
@property (nonatomic, assign) size_t fileSize;
@property (nonatomic, assign) int progressIndex;

@end

@implementation FPMultipartUpload

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

- (instancetype)initWithLocalURL:(NSURL *)localURL
                        filename:(NSString *)filename
                     andMimetype:(NSString *)mimetype
{
    self = [self init];

    if (self)
    {
        NSAssert(localURL, @"LocalURL must be provided");
        NSAssert(mimetype, @"Mimetype must be provided");

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

- (FPUploadAssetSuccessBlock)successBlock
{
    if (!_successBlock)
    {
        _successBlock = ^(id JSON) {
            NSLog(@"Upload succeeded with response: %@", JSON);
        };
    }

    return _successBlock;
}

- (FPUploadAssetFailureBlock)failureBlock
{
    if (!_failureBlock)
    {
        _failureBlock = ^(NSError *error, id JSON) {
            NSLog(@"FAILURE %@ %@", error, JSON);
            assert(false);
        };
    }

    return _failureBlock;
}

- (void)upload
{
    [self uploadWithRetries:fpNumRetries];
}

- (void)uploadWithRetries:(int)retries
{
    dispatch_semaphore_wait([self.class lock_semaphore], DISPATCH_TIME_FOREVER);

    if (self.hasFinished)
    {
        NSLog(@"%@ already finished uploading.", self.filename);

        return;
    }

    NSDictionary *params = @{
        @"name":self.filename,
        @"filesize":@(self.fileSize),
        @"js_session":self.js_sessionString
    };

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSLog(@"Response: %@", responseObject);

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

    [[FPAPIClient sharedClient] POST:@"/api/path/computer/?multipart=start"
                          parameters:params
                             success:successOperationBlock
                             failure:failureOperationBlock];
}

#pragma mark - Private Methods

- (void)setup
{
    self.fileSize = [FPUtils fileSizeForLocalURL:self.localURL];

    NSAssert(self.fileSize > 0, @"File %@ is empty", self.localURL);

    self.inputStream = [NSInputStream inputStreamWithURL:self.localURL];
    self.totalChunks = (int)ceilf(1.0f * self.fileSize / fpMaxChunkSize);
    self.sentChunks = 0;
    self.progressIndex = 0;
    self.hasFinished = NO;

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

    self.js_sessionString = [FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                                   andMimetypes:nil];
}

- (void)uploadChunks
{
    NSLog(@"Filesize: %lu chunks: %d", (unsigned long)self.fileSize, (int)self.totalChunks);

    NSString *escapedSessionString = [FPUtils urlEncodeString:self.js_sessionString];
    uint8_t *chunkBuffer = malloc(sizeof(uint8_t) * fpMaxChunkSize);

    [self.inputStream open];

    /* send the chunks */

    for (int i = 0; i < self.totalChunks; i++)
    {
        NSLog(@"Sending slice #%d", i);

        NSString *uploadPath;

        uploadPath = [NSString stringWithFormat:@"/api/path/computer/?multipart=upload&id=%@&index=%d&js_session=%@",
                      self.uploadID,
                      i,
                      escapedSessionString];

        size_t actualBytesRead = [self.inputStream read:chunkBuffer
                                              maxLength:fpMaxChunkSize];

        if (actualBytesRead > 0)
        {
            NSData *dataSlice = [NSData dataWithBytes:chunkBuffer
                                               length:actualBytesRead];

            [self uploadChunkWithDataSlice:dataSlice
                                uploadPath:uploadPath
                                     index:i
                                     retry:fpNumRetries];
        }
        else
        {
            NSString *localizedErrorDescription = [NSString stringWithFormat:@"Tried to read from input stream but received: %lu",
                                                   (unsigned long)actualBytesRead];

            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:localizedErrorDescription};

            NSError *error = [NSError errorWithDomain:@"io.filepicker"
                                                 code:200
                                             userInfo:userInfo];

            [self finishWithError:error];
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

        NSLog(@"Send %d: %@ (sent: %d)", index, responseObject, self.sentChunks);

        if (self.sentChunks == self.totalChunks)
        {
            [self.inputStream close];
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

    [[FPAPIClient sharedClient] POST:@"/api/path/computer/?multipart=end"
                          parameters:params
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
