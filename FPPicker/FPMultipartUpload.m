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

@end

@implementation FPMultipartUpload

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

- (void)upload
{
    if (self.sentChunks == self.totalChunks)
    {
        NSLog(@"%@ has already been uploaded.", self.filename);

        return;
    }

    [self uploadWithRetries:fpNumRetries];
}

- (void)uploadWithRetries:(int)retries
{
    NSDictionary *params = @{
        @"name":self.filename,
        @"filesize":@(self.fileSize),
        @"js_session":self.js_sessionString
    };

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSLog(@"Response: %@", responseObject);

        self.uploadID = responseObject[@"data"][@"id"];

        [self uploadChunks];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (retries <= 1)
        {
            if (self.failureBlock)
            {
                self.failureBlock(error, nil);
            }
            else
            {
                NSAssert(true, error.description);
            }
        }
        else
        {
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

    self.totalChunks = (int)ceilf(1.0f * self.fileSize / fpMaxChunkSize);
    self.sentChunks = 0;
    self.progressTracker = [[FPProgressTracker alloc] initWithObjectCount:self.totalChunks];
    self.inputStream = [NSInputStream inputStreamWithURL:self.localURL];
    self.js_sessionString = [FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                                   andMimetypes:nil];
}

- (void)uploadChunks
{
    NSLog(@"Filesize: %lu chunks: %d", (unsigned long)self.fileSize, (int)self.totalChunks);

    NSString *escapedSessionString = [FPUtils urlEncodeString:self.js_sessionString];
    uint8_t *chunkBuffer = malloc(sizeof(uint8_t) * fpMaxChunkSize);

    NSData *dataSlice = [NSData dataWithBytesNoCopy:chunkBuffer
                                             length:fpMaxChunkSize
                                       freeWhenDone:YES];

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
            if (actualBytesRead < fpMaxChunkSize)
            {
                dataSlice = [dataSlice subdataWithRange:NSMakeRange(0, actualBytesRead)];
            }
        }
        else
        {
            NSString *errorString = [NSString stringWithFormat:@"Tried to read from input stream but received: %lu",
                                     (unsigned long)actualBytesRead];

            if (self.failureBlock)
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorString};

                NSError *error = [NSError errorWithDomain:@"io.filepicker"
                                                     code:200
                                                 userInfo:userInfo];

                self.failureBlock(error, nil);
            }
            else
            {
                NSAssert(true, errorString);
            }
        }

        [self uploadChunkWithDataSlice:dataSlice
                            uploadPath:uploadPath
                                 index:i
                                 retry:fpNumRetries];
    }
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
        if (self.progressBlock)
        {
            float overallProgress = [self.progressTracker setProgress:1.f
                                                               forKey:@(index)];

            self.progressBlock(overallProgress);
        }

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
            if (self.failureBlock)
            {
                self.failureBlock(error, nil);
            }
            else
            {
                NSAssert(true, error.description);
            }
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
        if (self.progressBlock && totalBytesExpectedToWrite > 0)
        {
            float overallProgress = [self.progressTracker setProgress:(1.0f * totalBytesWritten) / totalBytesExpectedToWrite
                                                               forKey:@(index)];

            self.progressBlock(overallProgress);
        }
    }];
}

- (void)endMultipartUploadWithRetries:(int)retries
{
    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if (self.successBlock)
        {
            self.successBlock(responseObject);
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (retries <= 1)
        {
            if (self.failureBlock)
            {
                self.failureBlock(error, nil);
            }
            else
            {
                NSAssert(true, error.description);
            }
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

@end
