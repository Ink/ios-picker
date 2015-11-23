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

#pragma mark - Query Methods

+ (void)requestObjectMediaInfo:(NSDictionary *)obj
                    withSource:(FPSource *)source
           usingOperationQueue:(NSOperationQueue *)operationQueue
                       success:(FPFetchObjectSuccessBlock)success
                       failure:(FPFetchObjectFailureBlock)failure
                      progress:(FPFetchObjectProgressBlock)progress
{
    NSURLRequest *request = [self requestForLoadPath:obj[@"link_path"]
                                          withFormat:@"data"
                                         queryString:nil
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

#pragma mark - Save As Methods

+ (void)     uploadData:(NSData *)filedata
                  named:(NSString *)filename
                 toPath:(NSString *)path
             ofMimetype:(NSString *)mimetype
    usingOperationQueue:(NSOperationQueue *)operationQueue
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
        // Clean up temporary file before returning the success response
        NSError *error;

        [[NSFileManager defaultManager] removeItemAtURL:tempURL
                                                  error:&error];

        if (error)
        {
            DLog(@"Error deleting temporary file at %@: %@", tempURL, error);
        }

        // Return success response
        success(JSON);
    };

    [self uploadDataURL:tempURL
                   named:filename
                  toPath:path
              ofMimetype:mimetype
     usingOperationQueue:operationQueue
                 success:successBlock
                 failure:failure
                progress:progress];
}

+ (void)  uploadDataURL:(NSURL *)localURL
                  named:(NSString *)filename
                 toPath:(NSString *)path
             ofMimetype:(NSString *)mimetype
    usingOperationQueue:(NSOperationQueue *)operationQueue
                success:(FPUploadAssetSuccessBlock)success
                failure:(FPUploadAssetFailureBlock)failure
               progress:(FPUploadAssetProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        NSString *filepickerURL = JSON[@"data"][0][@"url"];

        [FPLibrary uploadDataHelper_saveAs:filepickerURL
                                    toPath:[NSString stringWithFormat:@"%@%@", path, filename]
                                ofMimetype:mimetype
                       usingOperationQueue:operationQueue
                                   success:success
                                   failure:failure];
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error,
                                               id JSON) {
        DLog(@"File upload failed with %@, response was: %@", error, JSON);

        failure(error, JSON);
    };

    [FPLibrary uploadLocalURLToFilepicker:localURL
                                    named:filename
                               ofMimetype:mimetype
                      usingOperationQueue:operationQueue
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
}

#pragma mark - Private Methods

+ (void)uploadDataHelper_saveAs:(NSString *)fileLocation
                         toPath:(NSString *)saveLocation
                     ofMimetype:(NSString *)mimetype
            usingOperationQueue:(NSOperationQueue *)operationQueue
                        success:(FPUploadAssetSuccessBlock)success
                        failure:(FPUploadAssetFailureBlock)failure
{
    FPSession *fpSession = [FPSession sessionForFileUploads];;
    fpSession.mimetypes = mimetype;

    NSDictionary *params = @{
        @"js_session":[fpSession JSONSessionString],
        @"url":[FPUtils filePickerLocationWithOptionalSecurityFor:fileLocation]
    };

    NSString *savePath = [NSString stringWithFormat:@"/api/path%@", [FPUtils urlEncodeString:saveLocation]];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if (responseObject[@"url"])
        {
            success(responseObject);
        }
        else
        {
            NSError *error = [FPUtils errorWithCode:200
                            andLocalizedDescription         :@"Response does not contain an URL."];

            failure(error, responseObject);
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error, nil);
    };

    [[FPAPIClient sharedClient] POST:savePath
                          parameters:params
                 usingOperationQueue:operationQueue
                             success:successOperationBlock
                             failure:failureOperationBlock];
}

+ (void)uploadLocalURLToFilepicker:(NSURL *)localURL
                             named:(NSString *)filename
                        ofMimetype:(NSString *)mimetype
               usingOperationQueue:(NSOperationQueue *)operationQueue
                           success:(FPUploadAssetSuccessBlock)success
                           failure:(FPUploadAssetFailureBlock)failure
                          progress:(FPUploadAssetProgressBlock)progress
{
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
//                                                             mimetype:mimetype
//                                                    andOperationQueue:operationQueue];
//    }
//    else
    {
        DLog(@"Uploading multipart");

        fileUploader = [[FPMultipartUploader alloc] initWithLocalURL:localURL
                                                            filename:filename
                                                            mimetype:mimetype
                                                   andOperationQueue:operationQueue];
    }

    fileUploader.successBlock = success;
    fileUploader.failureBlock = failure;
    fileUploader.progressBlock = progress;

    [fileUploader upload];
}

+ (NSURLRequest *)requestForLoadPath:(NSString *)loadpath
                          withFormat:(NSString *)type
                         queryString:(NSString *)queryString
                        andMimetypes:(NSArray *)mimetypes
                         cachePolicy:(NSURLRequestCachePolicy)policy
{
    FPSession *fpSession = [FPSession sessionForFileUploads];
    fpSession.mimetypes = mimetypes;

    NSString *escapedSessionString = [FPUtils urlEncodeString:[fpSession JSONSessionString]];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:fpBASE_URL];

    urlComponents.query = queryString;
    urlComponents.path = [NSString stringWithFormat:@"/api/path%@", loadpath];

    NSArray *queryItems = @[
        [NSURLQueryItem queryItemWithName:@"format" value:type],
        [NSURLQueryItem queryItemWithName:@"js_session" value:escapedSessionString],
    ];

    if (urlComponents.queryItems)
    {
        urlComponents.queryItems = [urlComponents.queryItems arrayByAddingObjectsFromArray:queryItems];
    }
    else
    {
        urlComponents.queryItems = queryItems;
    }

    NSMutableURLRequest * mRequest = [NSMutableURLRequest requestWithURL:urlComponents.URL
                                                             cachePolicy:policy
                                                         timeoutInterval:240];

    [mRequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:fpCOOKIES]];

    return [mRequest copy];
}

@end
