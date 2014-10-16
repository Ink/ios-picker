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
    size_t fileSize = [FPUtils fileSizeForLocalURL:localURL];

    if (fileSize <= fpMaxChunkSize)
    {
        DLog(@"Uploading singlepart");

        fileUploader = [[FPSinglepartUploader alloc] initWithLocalURL:localURL
                                                             filename:filename
                                                          andMimetype:mimetype];
    }
    else
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

@end
