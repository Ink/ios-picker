//
//  FPLibrary.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPLibrary.h"
#import "FPSinglepartUploader.h"
#import "FPMultipartUploader.h"

@implementation FPLibrary

#pragma mark - Queues

+ (dispatch_queue_t)upload_processing_queue
{
    static dispatch_queue_t _upload_processing_queue;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _upload_processing_queue = dispatch_queue_create("io.filepicker.upload.processing.queue",
                                                         DISPATCH_QUEUE_SERIAL);
    });

    return _upload_processing_queue;
}

#pragma mark - Query Methods

+ (void)requestObjectMediaInfo:(NSDictionary *)obj
                    withSource:(FPSource *)source
           usingOperationQueue:(NSOperationQueue *)operationQueue
                shouldDownload:(BOOL)shouldDownload
                       success:(FPFetchObjectSuccessBlock)success
                       failure:(FPFetchObjectFailureBlock)failure
                      progress:(FPFetchObjectProgressBlock)progress
{
    if (shouldDownload)
    {
        [self getObjectInfoAndData:obj
                         forSource:source
               usingOperationQueue:operationQueue
                           success:success
                           failure:failure
                          progress:progress];
    }
    else
    {
        [self getObjectInfo:obj
                   forSource:source
         usingOperationQueue:operationQueue
                     success:success
                     failure:failure
                    progress:progress];
    }
}

#pragma mark - Save As Methods

+ (void)uploadData:(NSData *)filedata
             named:(NSString *)filename
            toPath:(NSString *)path
        ofMimetype:(NSString *)mimetype
       withOptions:(NSDictionary *)options
           success:(FPUploadAssetSuccessBlock)success
           failure:(FPUploadAssetFailureBlock)failure
          progress:(FPUploadAssetProgressBlock)progress
{
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
        DLog(@"File upload failed with %@, response was: %@", error, JSON);

        failure(error, JSON);
    };

    [FPLibrary uploadLocalURLToFilepicker:tempURL
                                    named:filename
                               ofMimetype:mimetype
                             shouldUpload:YES
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
}

+ (void)uploadDataURL:(NSURL *)filedataurl
                named:(NSString *)filename
               toPath:(NSString *)path
           ofMimetype:(NSString *)mimetype
          withOptions:(NSDictionary *)options
              success:(FPUploadAssetSuccessBlock)success
              failure:(FPUploadAssetFailureBlock)failure
             progress:(FPUploadAssetProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        NSString *filepickerURL = JSON[@"data"][0][@"url"];

        [FPLibrary uploadDataHelper_saveAs:filepickerURL
                                    toPath:[NSString stringWithFormat:@"%@%@", path, filename]
                                ofMimetype:mimetype
                               withOptions:options
                                   success:success
                                   failure:failure];
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error,
                                               id JSON) {
        DLog(@"File upload failed with %@, response was: %@", error, JSON);

        failure(error, JSON);
    };

    [FPLibrary uploadLocalURLToFilepicker:filedataurl
                                    named:filename
                               ofMimetype:mimetype
                             shouldUpload:YES
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
}

#pragma mark - Private Methods

+ (void)uploadDataHelper_saveAs:(NSString *)fileLocation
                         toPath:(NSString *)saveLocation
                     ofMimetype:(NSString *)mimetype
                    withOptions:(NSDictionary *)options
                        success:(FPUploadAssetSuccessBlock)success
                        failure:(FPUploadAssetFailureBlock)failure
{
    FPSession *fpSession = [FPSession new];

    fpSession.APIKey = fpAPIKEY;
    fpSession.mimetypes = mimetype;

    NSDictionary *params = @{
        @"js_session":[fpSession JSONSessionString],
        @"url":[FPUtils filePickerLocationWithOptionalSecurityFor:fileLocation]
    };

    NSString *savePath = [NSString stringWithFormat:@"/api/path%@", [FPUtils urlEncodeString:saveLocation]];

    DLog(@"Saving %@ (params: %@)", savePath, params);

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if (responseObject[@"url"])
        {
            DLog(@"Success with response %@", responseObject);

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
        DLog(@"File upload failed with %@", error);

        failure(error, nil);
    };

    [[FPAPIClient sharedClient] POST:savePath
                          parameters:params
                             success:successOperationBlock
                             failure:failureOperationBlock];
}

+ (void)uploadLocalURLToFilepicker:(NSURL *)localURL
                             named:(NSString *)filename
                        ofMimetype:(NSString *)mimetype
                      shouldUpload:(BOOL)shouldUpload
                           success:(FPUploadAssetSuccessBlock)success
                           failure:(FPUploadAssetFailureBlock)failure
                          progress:(FPUploadAssetProgressBlock)progress
{
    if (!shouldUpload)
    {
        DLog(@"Not uploading");

        NSError *error = [FPUtils errorWithCode:200
                          andLocalizedDescription:@"Should upload flag is set to NO."];

        failure(error, nil);

        return;
    }

    // Initialize preprocessors

    FPVideoUploadPreprocessorBlock videoUploadPreprocessorBlock = [FPConfig sharedInstance].videoUploadPreprocessorBlock;
    FPImageUploadPreprocessorBlock imageUploadPreprocessorBlock = [FPConfig sharedInstance].imageUploadPreprocessorBlock;

    // Apply preprocessors

    if ([mimetype isEqualToString:@"video/quicktime"] &&
        videoUploadPreprocessorBlock)
    {
        videoUploadPreprocessorBlock(localURL);
    }
    else if ((([mimetype isEqualToString:@"image/png"]) ||
              ([mimetype isEqualToString:@"image/jpeg"])) &&
             imageUploadPreprocessorBlock)
    {
        imageUploadPreprocessorBlock(localURL, mimetype);
    }

    // Do upload

    FPUploader *fileUploader;

    // NOTE: Singlepart uploads are currently not working on the server side (?)

//    size_t fileSize = [FPUtils fileSizeForLocalURL:localURL];
//
//
//    if (fileSize <= fpMaxChunkSize)
//    {
//        DLog(@"Uploading singlepart");
//
//        fileUploader = [[FPSinglepartUploader alloc] initWithLocalURL:localURL
//                                                             filename:filename
//                                                          andMimetype:mimetype];
//    }
//    else
    {
        DLog(@"Uploading multipart");

        fileUploader = [[FPMultipartUploader alloc] initWithLocalURL:localURL
                                                            filename:filename
                                                         andMimetype:mimetype];
    }

    fileUploader.successBlock = success;
    fileUploader.failureBlock = failure;
    fileUploader.progressBlock = progress;

    [fileUploader upload];
}

+ (void)  getObjectInfo:(NSDictionary *)obj
              forSource:(FPSource *)source
    usingOperationQueue:(NSOperationQueue *)operationQueue
                success:(FPFetchObjectSuccessBlock)success
                failure:(FPFetchObjectFailureBlock)failure
               progress:(FPFetchObjectProgressBlock)progress
{
    NSURLRequest *request = [self requestForLoadPath:obj[@"link_path"]
                                          withFormat:@"fpurl"
                                        andMimetypes:source.mimetypes
                                         cachePolicy:NSURLRequestReloadRevalidatingCacheData];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        FPMediaInfo *mediaInfo = [FPMediaInfo new];

        mediaInfo.remoteURL = [NSURL URLWithString:responseObject[@"url"]];
        mediaInfo.filename = responseObject[@"filename"];
        mediaInfo.key = responseObject[@"key"];
        mediaInfo.source = source;

        success(mediaInfo);
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error);
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [operation setDownloadProgressBlock: ^(NSUInteger bytesRead,
                                           long long totalBytesRead,
                                           long long totalBytesExpectedToRead) {
        if (progress && totalBytesExpectedToRead > 0)
        {
            progress(1.0f * totalBytesRead / totalBytesExpectedToRead);
        }
    }];

    [operationQueue addOperation:operation];
}

+ (void)getObjectInfoAndData:(NSDictionary *)obj
                   forSource:(FPSource *)source
         usingOperationQueue:(NSOperationQueue *)operationQueue
                     success:(FPFetchObjectSuccessBlock)success
                     failure:(FPFetchObjectFailureBlock)failure
                    progress:(FPFetchObjectProgressBlock)progress
{
    NSURLRequest *request = [self requestForLoadPath:obj[@"link_path"]
                                          withFormat:@"data"
                                        andMimetypes:source.mimetypes
                                         cachePolicy:NSURLRequestReloadRevalidatingCacheData];

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPUtils genRandStringLength:20]];

    NSURL *tempURL = [NSURL fileURLWithPath:tempPath
                                isDirectory:NO];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSDictionary *headers = [operation.response allHeaderFields];
        NSString *mimetype = headers[@"Content-Type"];

        if ([mimetype rangeOfString:@";"].location != NSNotFound)
        {
            mimetype = [mimetype componentsSeparatedByString:@";"][0];
        }

        FPMediaInfo *mediaInfo = [FPMediaInfo new];

        mediaInfo.remoteURL = [NSURL URLWithString:headers[@"X-Data-Url"]];
        mediaInfo.filename = headers[@"X-File-Name"];
        mediaInfo.mediaURL = tempURL;
        mediaInfo.mediaType = [FPUtils UTIForMimetype:mimetype];
        mediaInfo.source = source;
        
        NSString *sizeString = headers[@"X-File-Size"];
        mediaInfo.filesize = [NSNumber numberWithInteger:[sizeString integerValue]];

        if (headers[@"X-Data-Key"])
        {
            mediaInfo.key = headers[@"X-Data-Key"];
        }

        success(mediaInfo);
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error);
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    operation.outputStream = [NSOutputStream outputStreamWithURL:tempURL
                                                          append:NO];

    [operation setDownloadProgressBlock: ^(NSUInteger bytesRead,
                                           long long totalBytesRead,
                                           long long totalBytesExpectedToRead) {
        if (progress && totalBytesExpectedToRead > 0)
        {
            progress(1.0f * totalBytesRead / totalBytesExpectedToRead);
        }
    }];

    [operationQueue addOperation:operation];
}

+ (NSURLRequest *)requestForLoadPath:(NSString *)loadpath
                          withFormat:(NSString *)type
                        andMimetypes:(NSArray *)mimetypes
                         cachePolicy:(NSURLRequestCachePolicy)policy
{
    return [self requestForLoadPath:loadpath
                         withFormat:type
                       andMimetypes:mimetypes
                        byAppending:@""
                        cachePolicy:policy];
}

+ (NSURLRequest *)requestForLoadPath:(NSString *)loadpath
                          withFormat:(NSString *)type
                        andMimetypes:(NSArray *)mimetypes
                         byAppending:(NSString *)additionalString
                         cachePolicy:(NSURLRequestCachePolicy)policy
{
    FPSession *fpSession = [FPSession new];

    fpSession.APIKey = fpAPIKEY;
    fpSession.mimetypes = mimetypes;

    NSString *escapedSessionString = [FPUtils urlEncodeString:[fpSession JSONSessionString]];

    NSMutableString *urlString = [NSMutableString stringWithString:[fpBASE_URL stringByAppendingString:[@"/api/path" stringByAppendingString : loadpath]]];

    if ([urlString rangeOfString:@"?"].location == NSNotFound)
    {
        [urlString appendFormat:@"?format=%@&%@=%@", type, @"js_session", escapedSessionString];
    }
    else
    {
        [urlString appendFormat:@"&format=%@&%@=%@", type, @"js_session", escapedSessionString];
    }

    [urlString appendString:additionalString];

    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:policy
                                                        timeoutInterval:240];

    [mRequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:fpCOOKIES]];

    return mRequest;
}

@end
