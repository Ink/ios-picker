//
//  FPLibrary.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPLibrary.h"
#import "FPInternalHeaders.h"
#import "FPUtils.h"
#import "FPSession+ConvenienceMethods.h"
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

#pragma mark - Camera Upload Methods

+ (void)uploadImage:(UIImage *)image
         ofMimetype:(NSString *)mimetype
        withOptions:(NSDictionary *)options
       shouldUpload:(BOOL)shouldUpload
            success:(FPUploadAssetSuccessWithLocalURLBlock)success
            failure:(FPUploadAssetFailureWithLocalURLBlock)failure
           progress:(FPUploadAssetProgressBlock)progress
{
    NSString *filename;
    NSData *filedata;

    DONT_BLOCK_UI();

    NSURL *tempURL = [FPUtils genRandTemporaryURLWithFileLength:20];

    image = [FPUtils fixImageRotationIfNecessary:image];

    if ([mimetype isEqualToString:@"image/png"])
    {
        filedata = UIImagePNGRepresentation(image);
        filename = @"camera.png";
    }
    else
    {
        filedata = UIImageJPEGRepresentation(image, 1.0);
        filename = @"camera.jpg";
    }

    [filedata writeToURL:tempURL
              atomically:YES];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success(JSON, tempURL);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        DLog(@"File upload failed with %@, response was: %@", error, JSON);

        failure(error, JSON, tempURL);
    };

    [FPLibrary uploadLocalURLToFilepicker:tempURL
                                    named:filename
                               ofMimetype:mimetype
                             shouldUpload:shouldUpload
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
}

+ (void)uploadVideoURL:(NSURL *)url
           withOptions:(NSDictionary *)options
          shouldUpload:(BOOL)shouldUpload
               success:(FPUploadAssetSuccessWithLocalURLBlock)success
               failure:(FPUploadAssetFailureWithLocalURLBlock)failure
              progress:(FPUploadAssetProgressBlock)progress
{
    NSString *filename = @"movie.MOV";
    NSString *mimetype = @"video/quicktime";

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success(JSON, url);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        DLog(@"File upload failed with %@, response was: %@", error, JSON);

        failure(error, JSON, url);
    };

    [FPLibrary uploadLocalURLToFilepicker:url
                                    named:filename
                               ofMimetype:mimetype
                             shouldUpload:shouldUpload
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
}

#pragma mark - Local Source Upload Methods

+ (void)uploadAsset:(ALAsset *)asset
        withOptions:(NSDictionary *)options
       shouldUpload:(BOOL)shouldUpload
            success:(FPUploadAssetSuccessWithLocalURLBlock)success
            failure:(FPUploadAssetFailureWithLocalURLBlock)failure
           progress:(FPUploadAssetProgressBlock)progress
{
    dispatch_sync([self upload_processing_queue], ^{
        NSURL *tempURL = [FPUtils genRandTemporaryURLWithFileLength:20];
        NSString *filename = asset.defaultRepresentation.filename;
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        CFStringRef utiToConvert = (__bridge CFStringRef)representation.UTI;

        NSString *mimetype = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(utiToConvert,
                                                                                           kUTTagClassMIMEType);

        DLog(@"Copying %@", mimetype);

        [FPUtils copyAssetRepresentation:representation
                            intoLocalURL:tempURL];

        FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
            success(JSON, tempURL);
        };

        FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
            DLog(@"File upload failed with %@, response was: %@", error, JSON);

            failure(error, JSON, tempURL);
        };

        [FPLibrary uploadLocalURLToFilepicker:tempURL
                                        named:filename
                                   ofMimetype:mimetype
                                 shouldUpload:shouldUpload
                                      success:successBlock
                                      failure:failureBlock
                                     progress:progress];
    });
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

        NSError *error = [NSError errorWithDomain:@"io.filepicker"
                                             code:200
                                         userInfo:nil];
        failure(error, nil);

        return;
    }

    // Initialize preprocessors

    FPVideoUploadPreprocessorBlock videoUploadPreprocessorBlock = [FPConfig sharedInstance].videoUploadPreprocessorBlock;
    FPImageUploadPreprocessorBlock imageUploadPreprocessorBlock = [FPConfig sharedInstance].imageUploadPreprocessorBlock;

    if (!imageUploadPreprocessorBlock)
    {
        imageUploadPreprocessorBlock = ^(NSURL *localURL,
                                         NSString *mimetype) {
            if ([mimetype isEqualToString:@"image/jpeg"])
            {
                DLog(@"Compressing JPEG");

                UIImage *image = [UIImage imageWithContentsOfFile:localURL.path];
                NSData *filedata = UIImageJPEGRepresentation(image, 0.6);

                [filedata writeToURL:localURL
                          atomically:YES];
            }
        };
    }

    // Apply preprocessors

    if ([mimetype isEqualToString:@"video/quicktime"])
    {
        videoUploadPreprocessorBlock(localURL);
    }
    else if (([mimetype isEqualToString:@"image/png"]) ||
             ([mimetype isEqualToString:@"image/jpeg"]))
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
