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

    NSData *filedata = [NSData dataWithContentsOfURL:fileURL];

    NSInteger filesize = filedata.length;

    if (filesize <= fpMaxChunkSize)
    {
        NSLog(@"Uploading singlepart");

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

        [FPLibrary multipartUploadData:filedata
                                 named:filename
                            ofMimetype:mimetype
                               success:success
                               failure:failure
                              progress:progress];
    }
}

//single file upload
+ (void)singlepartUploadData:(NSData*)filedata
                       named:(NSString*)filename
                  ofMimetype:(NSString*)mimetype
                     success:(FPUploadAssetSuccessBlock)success
                     failure:(FPUploadAssetFailureBlock)failure
                    progress:(FPUploadAssetProgressBlock)progress
{
    NSURL *url = [NSURL URLWithString:fpBASE_URL];
    FPAFHTTPClient *httpClient = [[FPAFHTTPClient alloc] initWithBaseURL:url];

    NSString *appString = [NSString stringWithFormat:@"{\"apikey\": \"%@\"}", fpAPIKEY];
    NSString *js_sessionString = [NSString stringWithFormat:@"{\"app\": %@}", appString];

    NSDictionary *params = @{@"js_session":js_sessionString};

    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:@"/api/path/computer/"
                                                                   parameters:params
                                                    constructingBodyWithBlock: ^(id <FPAFMultipartFormData>formData) {
        [formData appendPartWithFileData:filedata
                                    name:@"fileUpload"
                                fileName:filename
                                mimeType:mimetype];
    }];

    FPARequestOperationSuccessBlock successOperationBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([@"ok" isEqual :[JSON valueForKey:@"result"]])
        {
            success(JSON);
        }
        else
        {
            failure([[NSError alloc] initWithDomain:@"FPPicker"
                                               code:0
                                           userInfo:nil], JSON);
        }
    };

    FPARequestOperationFailureBlock failureOperationBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error, JSON);
    };

    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                            success:successOperationBlock
                                                                                            failure:failureOperationBlock];

    [operation setUploadProgressBlock: ^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        if (totalBytesExpectedToWrite > 0)
        {
            progress(((float)totalBytesWritten) / totalBytesExpectedToWrite);
        }
    }];

    [operation start];
}

//multipart
// TODO: Refactor by splitting into smaller and more manageable parts

+ (void)multipartUploadData:(NSData*)filedata
                      named:(NSString*)filename
                 ofMimetype:(NSString*)mimetype
                    success:(FPUploadAssetSuccessBlock)success
                    failure:(FPUploadAssetFailureBlock)failure
                   progress:(FPUploadAssetProgressBlock)progress
{
    __block BOOL hasFinished;
    __block int numberOfTries;

    NSInteger filesize = [filedata length];
    NSInteger numOfChunks = ceil(1.0 * filesize / fpMaxChunkSize);

    NSLog(@"Filesize: %ld chuncks: %ld", (long)filesize, (long)numOfChunks);


    NSURL *url = [NSURL URLWithString:fpBASE_URL];
    FPAFHTTPClient *httpClient = [[FPAFHTTPClient alloc] initWithBaseURL:url];

    NSString *appString = [NSString stringWithFormat:@"{\"apikey\": \"%@\"}", fpAPIKEY];
    NSString *js_sessionString = [NSString stringWithFormat:@"{\"app\": %@}", appString];

    /* begin multipart */


    if (!filename)
    {
        filename = @"filename";
    }

    NSDictionary *startParams = @{
        @"name":filename,
        @"filesize":@(filesize),
        @"js_session":js_sessionString
    };

    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"/api/path/computer/?multipart=start"
                                                      parameters:startParams];


    FPARequestOperationSuccessBlock beginPartSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Response: %@", JSON);
        NSString* upload_id = [[JSON valueForKey:@"data"] valueForKey:@"id"];

        void (^endMultipart)() = ^() {
            NSDictionary *endParams = @{
                @"id":upload_id,
                @"total":@(numOfChunks),
                @"js_session":js_sessionString
            };

            NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                    path:@"/api/path/computer/?multipart=end"
                                                              parameters:endParams];

            FPARequestOperationSuccessBlock endPartSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"DONE!: %@", JSON);
                hasFinished = YES;
                success(JSON);
            };

            FPARequestOperationFailureBlock endPartFail = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                if (numberOfTries >= fpNumRetries)
                {
                    NSLog(@"failed at the end: %@ %@", error, JSON);
                    hasFinished = YES;
                    failure(error, JSON);
                }
                else
                {
                    hasFinished = NO;
                    numberOfTries++;
                }
            };


            numberOfTries = 0;
            hasFinished = NO;

            while (!hasFinished)
            {
                [[FPAFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                   success:endPartSuccess
                                                                   failure:endPartFail] start];
            }
        };


        FPProgressTracker* progressTracker = [[FPProgressTracker alloc] initWithObjectCount:numOfChunks];
        __block int numberSent = 0;

        /* send the chunks */
        for (int i = 0; i < numOfChunks; i++)
        {
            NSString *uploadPath = [NSString stringWithFormat:@"/api/path/computer/?multipart=upload&id=%@&index=%d&js_session=%@",
                                    upload_id,
                                    i,
                                    [js_sessionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            NSLog(@"Sending slice #%d", i);

            NSData *slice;

            if (i == numOfChunks - 1)
            {
                NSInteger finalPartSize = filesize - i * fpMaxChunkSize;
                slice = [NSData dataWithBytesNoCopy:(void*)[[filedata subdataWithRange:NSMakeRange(i * fpMaxChunkSize, finalPartSize)] bytes]
                                             length:finalPartSize
                                       freeWhenDone:NO];
            }
            else
            {
                slice = [NSData dataWithBytesNoCopy:(void*)[[filedata subdataWithRange:NSMakeRange(i * fpMaxChunkSize, fpMaxChunkSize)] bytes]
                                             length:fpMaxChunkSize
                                       freeWhenDone:NO];
            }

            NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                                 path:uploadPath
                                                                           parameters:nil
                                                            constructingBodyWithBlock: ^(id <FPAFMultipartFormData>formData) {
                [formData appendPartWithFileData:slice
                                            name:@"fileUpload"
                                        fileName:filename
                                        mimeType:mimetype];
            }];

            [request setHTTPShouldUsePipelining:YES];


            FPARequestOperationSuccessBlock onePartSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                float overallProgress = [progressTracker setProgress:1.f
                                                              forKey:@(i)];
                progress(overallProgress);
                numberSent++;

                NSLog(@"Send %d: %@ (sent: %d)", i, JSON, numberSent);

                if (numberSent == numOfChunks)
                {
                    hasFinished = YES;
                    endMultipart();
                }
            };

            FPARequestOperationFailureBlock onePartFail = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                if (numberOfTries > fpNumRetries)
                {
                    NSLog(@"Fail: %@ %@", error, JSON);
                    hasFinished = YES;
                    failure(error, JSON);
                }
                else
                {
                    NSLog(@"Retrying part %d time: %d", i, numberOfTries);
                    numberOfTries++;
                    hasFinished = NO;
                }
            };


            numberOfTries = 0;
            hasFinished = NO;

            while (!hasFinished)
            {
                FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                                        success:onePartSuccess
                                                                                                        failure:onePartFail];

                [operation setUploadProgressBlock: ^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
                    if (totalBytesExpectedToWrite > 0)
                    {
                        float overallProgress = [progressTracker setProgress:((float)totalBytesWritten) / totalBytesExpectedToWrite
                                                                      forKey:@(i)];
                        progress(overallProgress);
                    }
                }];

                [operation start];
            }
        }

        ;
    };

    FPARequestOperationFailureBlock beginPartFail = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (numberOfTries > fpNumRetries)
        {
            NSLog(@"Response error: %@ %@", error, JSON);
            hasFinished = YES;
            failure(error, JSON);
        }
        else
        {
            numberOfTries++;
            hasFinished = NO;
        }
    };


    numberOfTries = 0;
    hasFinished = NO;

    while (!hasFinished)
    {
        [[FPAFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                           success:beginPartSuccess
                                                           failure:beginPartFail] start];
    }
}

#pragma mark camera upload

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

#pragma mark local source controller

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
        if (representation.size > SIZE_T_MAX)
        {
            NSLog(@"ERROR: Asset size %lld too large. Max allowed size: %ld",
                  representation.size,
                  SIZE_T_MAX);

            return;
        }

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

        UIImage* image = [UIImage imageWithCGImage:representation.fullResolutionImage
                                             scale:representation.scale
                                       orientation:(UIImageOrientation)representation.orientation];

        filedata = UIImagePNGRepresentation(image);
    }
    else
    {
        NSLog(@"using jpeg");

        UIImage* image = [UIImage imageWithCGImage:representation.fullResolutionImage
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

#pragma mark for save as

+ (void)uploadData:(NSData*)filedata
             named:(NSString *)filename
            toPath:(NSString*)path
        ofMimetype:(NSString*)mimetype
       withOptions:(NSDictionary*)options
           success:(FPUploadAssetSuccessBlock)success
           failure:(FPUploadAssetFailureBlock)failure
          progress:(FPUploadAssetProgressBlock)progress
{
    NSLog(@"Type: %@", mimetype);
    //NSString *mimetype = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    //NSLog(@"Mime: %@", mimetype);

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPUtils genRandStringLength:20]];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath isDirectory:NO];
    [filedata writeToURL:tempURL atomically:YES];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        NSString *filepickerURL = [[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"url"];

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
    NSLog(@"Type: %@", mimetype);
    //NSString *mimetype = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    //NSLog(@"Mime: %@", mimetype);

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        NSString *filepickerURL = [[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"url"];

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

+ (void)uploadDataHelper_saveAs:(NSString *)fileLocation
                         toPath:(NSString*)saveLocation
                     ofMimetype:(NSString*)mimetype
                    withOptions:(NSDictionary*)options
                        success:(FPUploadAssetSuccessBlock)success
                        failure:(FPUploadAssetFailureBlock)failure
{
    FPAFHTTPClient *httpClient = [[FPAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fpBASE_URL]];

    NSString *appString = [NSString stringWithFormat:@"{\"apikey\": \"%@\"}", fpAPIKEY];
    NSString *js_sessionString = [NSString stringWithFormat:@"{\"app\": %@, \"mimetypes\":[\"%@\"] }", appString, mimetype];

    NSDictionary *params = @{
        @"js_session":js_sessionString,
        @"url":fileLocation
    };

    NSString *savePath = [NSString stringWithFormat:@"/api/path%@",
                          [saveLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:savePath
                                                      parameters:params];

    NSLog(@"Saving %@", request);

    FPARequestOperationSuccessBlock operationSuccessBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([JSON valueForKey:@"url"])
        {
            success(JSON);
        }
        else
        {
            failure([[NSError alloc] initWithDomain:fpBASE_URL
                                               code:0
                                           userInfo:nil],
                    JSON);
        }
    };

    FPARequestOperationFailureBlock operationFailureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error, JSON);
    };

    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                            success:operationSuccessBlock
                                                                                            failure:operationFailureBlock];
    [operation start];
}

@end
