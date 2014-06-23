//
//  FPLibrary.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPLibrary.h"
#import "FPInternalHeaders.h"
#import "FPProgressTracker.h"
#import "FPUtils.h"

@implementation FPLibrary

#pragma mark - Camera Upload Methods

+ (void)uploadImage:(UIImage*)image
         ofMimetype:(NSString*)mimetype
        withOptions:(NSDictionary*)options
       shouldUpload:(BOOL)shouldUpload
            success:(FPUploadAssetSuccessWithLocalURLBlock)success
            failure:(FPUploadAssetFailureWithLocalURLBlock)failure
           progress:(FPUploadAssetProgressBlock)progress
{
    NSString *filename;
    NSData *filedata;

    DONT_BLOCK_UI();

    image = [FPUtils fixImageRotationIfNecessary:image];

    if ([mimetype isEqualToString:@"image/png"])
    {
        filedata = UIImagePNGRepresentation(image);
        filename = @"camera.png";
    }
    else
    {
        filedata = UIImageJPEGRepresentation(image, 0.6);
        filename = @"camera.jpg";
    }

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPUtils genRandStringLength:20]];

    NSURL *tempURL = [NSURL fileURLWithPath:tempPath
                                isDirectory:NO];

    [filedata writeToURL:tempURL
              atomically:YES];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success(JSON, tempURL);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSLog(@"FAILURE %@ %@", error, JSON);
        failure(error, JSON, tempURL);
    };

    [FPLibrary uploadDataToFilepicker:tempURL
                                named:filename
                           ofMimetype:mimetype
                         shouldUpload:shouldUpload
                              success:successBlock
                              failure:failureBlock
                             progress:progress];
}

+ (void)uploadVideoURL:(NSURL*)url
           withOptions:(NSDictionary*)options
          shouldUpload:(BOOL)shouldUpload
               success:(FPUploadAssetSuccessWithLocalURLBlock)success
               failure:(FPUploadAssetFailureWithLocalURLBlock)failure
              progress:(FPUploadAssetProgressBlock)progress
{
    NSString *filename = @"movie.MOV";
    NSString * mimetype = @"video/quicktime";

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success(JSON, url);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSLog(@"FAILURE %@ %@", error, JSON);
        failure(error, JSON, url);
    };

    [FPLibrary uploadDataToFilepicker:url
                                named:filename
                           ofMimetype:mimetype
                         shouldUpload:shouldUpload
                              success:successBlock
                              failure:failureBlock
                             progress:progress];
}

#pragma mark - Local Source Upload Methods

+ (void)uploadAsset:(ALAsset*)asset
        withOptions:(NSDictionary*)options
       shouldUpload:(BOOL)shouldUpload
            success:(FPUploadAssetSuccessWithLocalURLBlock)success
            failure:(FPUploadAssetFailureWithLocalURLBlock)failure
           progress:(FPUploadAssetProgressBlock)progress
{
    NSString *filename;
    NSData *filedata;

    ALAssetRepresentation *representation = asset.defaultRepresentation;

    CFStringRef utiToConvert = (__bridge CFStringRef)representation.UTI;
    NSString *mimetype = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass(utiToConvert,
                                                                                      kUTTagClassMIMEType);

    NSLog(@"mimetype: %@", mimetype);


    if ([mimetype isEqualToString:@"video/quicktime"])
    {
        size_t bufferLen = (size_t)representation.size;
        Byte *buffer = (Byte *)malloc(bufferLen);

        NSUInteger buffered = [representation getBytes:buffer
                                            fromOffset:0
                                                length:bufferLen
                                                 error:nil];

        filedata = [NSData dataWithBytesNoCopy:buffer
                                        length:buffered
                                  freeWhenDone:YES];
    }
    else if ([mimetype isEqualToString:@"image/png"])
    {
        NSLog(@"using png");

        UIImage *image = [UIImage imageWithCGImage:representation.fullResolutionImage
                                             scale:representation.scale
                                       orientation:(UIImageOrientation)representation.orientation];

        filedata = UIImagePNGRepresentation(image);
    }
    else
    {
        NSLog(@"using jpeg");

        UIImage *image = [UIImage imageWithCGImage:representation.fullResolutionImage
                                             scale:representation.scale
                                       orientation:(UIImageOrientation)representation.orientation];

        filedata = UIImageJPEGRepresentation(image, 0.6);
    }

    if ([representation respondsToSelector:@selector(filename)])
    {
        filename = representation.filename;
    }
    else
    {
        CFStringRef extension = UTTypeCopyPreferredTagWithClass(utiToConvert,
                                                                kUTTagClassFilenameExtension);

        filename = [NSString stringWithFormat:@"file.%@", CFBridgingRelease(extension)];
    }

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPUtils genRandStringLength:20]];

    NSURL *tempURL = [NSURL fileURLWithPath:tempPath
                                isDirectory:NO];

    [filedata writeToURL:tempURL
              atomically:YES];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success(JSON, tempURL);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSLog(@"FAILURE %@ %@", error, JSON);
        failure(error, JSON, tempURL);
    };

    [FPLibrary uploadDataToFilepicker:tempURL
                                named:filename
                           ofMimetype:mimetype
                         shouldUpload:shouldUpload
                              success:successBlock
                              failure:failureBlock
                             progress:progress];
}

#pragma mark - Save As Methods

+ (void)uploadData:(NSData*)filedata
             named:(NSString *)filename
            toPath:(NSString*)path
        ofMimetype:(NSString*)mimetype
       withOptions:(NSDictionary*)options
           success:(FPUploadAssetSuccessBlock)success
           failure:(FPUploadAssetFailureBlock)failure
          progress:(FPUploadAssetProgressBlock)progress
{
    NSLog(@"Mimetype: %@", mimetype);

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPUtils genRandStringLength:20]];

    NSURL *tempURL = [NSURL fileURLWithPath:tempPath
                                isDirectory:NO];

    [filedata writeToURL:tempURL
              atomically:YES];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        NSString *filepickerURL = JSON[@"data"][0][@"url"];

        [FPLibrary uploadDataHelper_saveAs:filepickerURL
                                    toPath:[NSString stringWithFormat:@"%@%@", path, filename]
                                ofMimetype:mimetype
                               withOptions:options
                                   success:success
                                   failure:failure];
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSLog(@"FAILURE %@ %@", error, JSON);
        failure(error, JSON);
    };

    [FPLibrary uploadDataToFilepicker:tempURL
                                named:filename
                           ofMimetype:mimetype
                         shouldUpload:YES
                              success:successBlock
                              failure:failureBlock
                             progress:progress];
}

+ (void)uploadDataURL:(NSURL*)filedataurl
                named:(NSString *)filename
               toPath:(NSString*)path
           ofMimetype:(NSString*)mimetype
          withOptions:(NSDictionary*)options
              success:(FPUploadAssetSuccessBlock)success
              failure:(FPUploadAssetFailureBlock)failure
             progress:(FPUploadAssetProgressBlock)progress
{
    NSLog(@"Mimetype: %@", mimetype);

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        NSString *filepickerURL = JSON[@"data"][0][@"url"];

        [FPLibrary uploadDataHelper_saveAs:filepickerURL
                                    toPath:[NSString stringWithFormat:@"%@%@", path, filename]
                                ofMimetype:mimetype
                               withOptions:options
                                   success:success
                                   failure:failure];
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSLog(@"FAILURE %@ %@", error, JSON);
        failure(error, JSON);
    };

    [FPLibrary uploadDataToFilepicker:filedataurl
                                named:filename
                           ofMimetype:mimetype
                         shouldUpload:YES
                              success:successBlock
                              failure:failureBlock
                             progress:progress];
}

#pragma mark - Private Methods

+ (void)uploadDataHelper_saveAs:(NSString *)fileLocation
                         toPath:(NSString*)saveLocation
                     ofMimetype:(NSString*)mimetype
                    withOptions:(NSDictionary*)options
                        success:(FPUploadAssetSuccessBlock)success
                        failure:(FPUploadAssetFailureBlock)failure
{
    NSString *js_sessionString = [FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                                        andMimetypes:mimetype];

    NSDictionary *params = @{
        @"js_session":js_sessionString,
        @"url":fileLocation
    };

    NSString *savePath = [NSString stringWithFormat:@"/api/path%@", [FPUtils urlEncodeString:saveLocation]];

    NSLog(@"Saving %@", savePath);

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if (responseObject[@"url"])
        {
            success(responseObject);
        }
        else
        {
            failure([[NSError alloc] initWithDomain:fpBASE_URL
                                               code:0
                                           userInfo:nil],
                    responseObject);
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error, nil);
    };

    [[FPAPIClient sharedClient] POST:savePath
                          parameters:params
                             success:successOperationBlock
                             failure:failureOperationBlock];
}

+ (void)uploadDataToFilepicker:(NSURL*)fileURL
                         named:(NSString*)filename
                    ofMimetype:(NSString*)mimetype
                  shouldUpload:(BOOL)shouldUpload
                       success:(FPUploadAssetSuccessBlock)success
                       failure:(FPUploadAssetFailureBlock)failure
                      progress:(FPUploadAssetProgressBlock)progress
{
    if (!shouldUpload)
    {
        NSLog(@"Not Uploading");

        NSError *error = [NSError errorWithDomain:@"io.filepicker"
                                             code:200
                                         userInfo:nil];
        failure(error, nil);

        return;
    }

    NSUInteger fileSize = [[self fileSizeForURL:fileURL] unsignedIntegerValue];

    if (fileSize <= fpMaxChunkSize)
    {
        NSLog(@"Uploading singlepart");

        NSData *filedata = [NSData dataWithContentsOfURL:fileURL];

        [FPLibrary singlepartUploadData:filedata
                                  named:filename
                             ofMimetype:mimetype
                                success:success
                                failure:failure
                               progress:progress];
    }
    else
    {
        NSLog(@"Uploading Multipart");

        [FPLibrary multipartUploadWithLocalURL:fileURL
                                         named:filename
                                    ofMimetype:mimetype
                                       success:success
                                       failure:failure
                                      progress:progress];
    }
}

+ (void)singlepartUploadData:(NSData*)filedata
                       named:(NSString*)filename
                  ofMimetype:(NSString*)mimetype
                     success:(FPUploadAssetSuccessBlock)success
                     failure:(FPUploadAssetFailureBlock)failure
                    progress:(FPUploadAssetProgressBlock)progress
{
    NSDictionary *params = @{
        @"js_session":[FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                             andMimetypes:nil]
    };

    AFConstructingBodyBlock constructingBodyBlock = ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:filedata
                                    name:@"fileUpload"
                                fileName:filename
                                mimeType:mimetype];
    };

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if ([@"ok" isEqual : responseObject[@"result"]])
        {
            success(responseObject);
        }
        else
        {
            failure([[NSError alloc] initWithDomain:@"FPPicker"
                                               code:0
                                           userInfo:nil], responseObject);
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error, nil);
    };

    AFHTTPRequestOperation *operation = [[FPAPIClient sharedClient] POST:@"/api/path/computer/"
                                                              parameters:params
                                               constructingBodyWithBlock:constructingBodyBlock
                                                                 success:successOperationBlock
                                                                 failure:failureOperationBlock];

    [operation setUploadProgressBlock: ^(NSUInteger bytesWritten,
                                         long long totalBytesWritten,
                                         long long totalBytesExpectedToWrite) {
        if (totalBytesExpectedToWrite > 0)
        {
            progress(((float)totalBytesWritten) / totalBytesExpectedToWrite);
        }
    }];
}

+ (void)multipartUploadWithLocalURL:(NSURL *)localURL
                              named:(NSString*)filename
                         ofMimetype:(NSString*)mimetype
                            success:(FPUploadAssetSuccessBlock)success
                            failure:(FPUploadAssetFailureBlock)failure
                           progress:(FPUploadAssetProgressBlock)progress
{
    void (^tryOperation)();
    __block int numberOfTries;

    if (!filename)
    {
        filename = @"filename";
    }

    NSNumber *fileSizeValue = [self fileSizeForURL:localURL];

    NSString *js_sessionString = [FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                                        andMimetypes:nil];
    NSDictionary *params = @{
        @"name":filename,
        @"filesize":fileSizeValue,
        @"js_session":js_sessionString
    };

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSLog(@"Response: %@", responseObject);

        [self processMultipartWithLocalURL:localURL
                                     named:filename
                                ofMimetype:mimetype
                              JSONResponse:responseObject
                                   success:success
                                   failure:failure
                                  progress:progress];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        NSLog(@"Operation failed with error: %@", error);

        if (numberOfTries > fpNumRetries)
        {
            NSLog(@"Response error: %@", error);
            failure(error, nil);
        }
        else
        {
            numberOfTries++;
            tryOperation();
        }
    };

    numberOfTries = 0;

    tryOperation = ^() {
        [[FPAPIClient sharedClient] POST:@"/api/path/computer/?multipart=start"
                              parameters:params
                                 success:successOperationBlock
                                 failure:failureOperationBlock];
    };

    tryOperation();
}

+ (void)processMultipartWithLocalURL:(NSURL *)localURL
                               named:(NSString*)filename
                          ofMimetype:(NSString*)mimetype
                        JSONResponse:(id)JSON
                             success:(FPUploadAssetSuccessBlock)success
                             failure:(FPUploadAssetFailureBlock)failure
                            progress:(FPUploadAssetProgressBlock)progress
{
    __block void (^tryOperation)();
    __block int numberOfTries;

    NSUInteger fileSize = [[self fileSizeForURL:localURL] unsignedIntegerValue];
    NSUInteger totalChunks = ceil(1.0 * fileSize / fpMaxChunkSize);

    NSString *uploadID = JSON[@"data"][@"id"];

    NSString *js_sessionString = [FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                                        andMimetypes:nil];

    NSLog(@"Response: %@", JSON);
    NSLog(@"Filesize: %ld chunks: %ld", (long)fileSize, (long)totalChunks);


    void (^endMultipart)() = ^() {
        NSDictionary *params = @{
            @"id":uploadID,
            @"total":@(totalChunks),
            @"js_session":js_sessionString
        };

        AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                                 id responseObject) {
            NSLog(@"DONE!: %@", responseObject);
            success(responseObject);
        };

        AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                                 NSError *error) {
            if (numberOfTries >= fpNumRetries)
            {
                NSLog(@"failed at the end: %@", error);
                failure(error, nil);
            }
            else
            {
                numberOfTries++;
                tryOperation();
            }
        };


        numberOfTries = 0;

        tryOperation = ^() {
            [[FPAPIClient sharedClient] POST:@"/api/path/computer/?multipart=end"
                                  parameters:params
                                     success:successOperationBlock
                                     failure:failureOperationBlock];
        };

        tryOperation();
    };


    FPProgressTracker* progressTracker = [[FPProgressTracker alloc] initWithObjectCount:totalChunks];
    NSString *escapedSessionString = [FPUtils urlEncodeString:js_sessionString];
    __block int sentChunks = 0;

    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:localURL];

    [inputStream open];

    /* send the chunks */

    for (int i = 0; i < totalChunks; i++)
    {
        NSLog(@"Sending slice #%d", i);

        NSString *uploadPath;

        uploadPath = [NSString stringWithFormat:@"/api/path/computer/?multipart=upload&id=%@&index=%d&js_session=%@",
                      uploadID,
                      i,
                      escapedSessionString];

        AFConstructingBodyBlock constructingBodyBlock = ^(id <AFMultipartFormData>formData) {
            uint8_t *chunkBuffer = malloc(sizeof(uint8_t) * fpMaxChunkSize);

            NSData *dataSlice = [NSData dataWithBytesNoCopy:chunkBuffer
                                                     length:fpMaxChunkSize
                                               freeWhenDone:YES];
            NSInteger actualBytesRead;

            actualBytesRead = [inputStream read:chunkBuffer
                                      maxLength:fpMaxChunkSize];

            if (actualBytesRead > 0)
            {
                dataSlice = [dataSlice subdataWithRange:NSMakeRange(0, actualBytesRead)];

                [formData appendPartWithFileData:dataSlice
                                            name:@"fileUpload"
                                        fileName:filename
                                        mimeType:mimetype];
            }
            else
            {
                NSLog(@"Tried to read from input stream but received: %ld", (long)actualBytesRead);
            }
        };

        AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                                 id responseObject) {
            float overallProgress = [progressTracker setProgress:1.f
                                                          forKey:@(i)];

            if (progress)
            {
                progress(overallProgress);
            }

            sentChunks++;

            NSLog(@"Send %d: %@ (sent: %d)", i, JSON, sentChunks);

            if (sentChunks == totalChunks)
            {
                [inputStream close];
                endMultipart();
            }
        };

        AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                                 NSError *error) {
            if (numberOfTries > fpNumRetries)
            {
                NSLog(@"Fail: %@", error);

                [inputStream close];
                failure(error, nil);
            }
            else
            {
                numberOfTries++;
                NSLog(@"Retrying part %d time: %d", i, numberOfTries);
                tryOperation();
            }
        };

        numberOfTries = 0;

        tryOperation = ^() {
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
                    float overallProgress = [progressTracker setProgress:((float)totalBytesWritten) / totalBytesExpectedToWrite
                                                                  forKey:@(i)];

                    progress(overallProgress);
                }
            }];
        };

        tryOperation();
    }
}

+ (NSNumber *)fileSizeForURL:(NSURL *)url
{
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;

    [url getResourceValue:&fileSizeValue
                   forKey:NSURLFileSizeKey
                    error:&fileSizeError];

    if (fileSizeError)
    {
        NSLog(@"Error when getting filesize of %@: %@", url, fileSizeError);
    }

    return fileSizeValue;
}

@end
