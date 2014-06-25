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
#import "FPMultipartUpload.h"

@implementation FPLibrary

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
        filedata = UIImageJPEGRepresentation(image, 0.6);
        filename = @"camera.jpg";
    }

    [filedata writeToURL:tempURL
              atomically:YES];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success(JSON, tempURL);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSLog(@"FAILURE %@ %@", error, JSON);
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
        NSLog(@"FAILURE %@ %@", error, JSON);
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
    ALAssetRepresentation *representation = asset.defaultRepresentation;

    CFStringRef utiToConvert = (__bridge CFStringRef)representation.UTI;

    NSString *mimetype = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass(utiToConvert,
                                                                                      kUTTagClassMIMEType);

    NSURL *tempURL = [FPUtils genRandTemporaryURLWithFileLength:20];

    NSLog(@"mimetype: %@", mimetype);

    if (([mimetype isEqualToString:@"video/quicktime"]) ||
        ([mimetype isEqualToString:@"image/png"]))
    {
        NSLog(@"Copying %@", mimetype);

        [FPUtils copyAssetRepresentation:representation
                            intoLocalURL:tempURL];
    }
    else
    {
        /*
            NOTE: This is another area that needs focus.

            We are compressing a full resolution JPEG image that is loaded fully into memory.
            This can easily cause memory pressure on the device.

            Alternatives:

            1. Just copy it (as we currently do with PNG and video)
            2. Compressing an smaller representation of the image.
         */

        NSLog(@"Compressing and copying JPEG");

        UIImage *image = [UIImage imageWithCGImage:representation.fullResolutionImage
                                             scale:representation.scale
                                       orientation:(UIImageOrientation)representation.orientation];

        NSData *filedata = UIImageJPEGRepresentation(image, 0.6);

        [filedata writeToURL:tempURL
                  atomically:YES];
    }

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success(JSON, tempURL);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSLog(@"FAILURE %@ %@", error, JSON);
        failure(error, JSON, tempURL);
    };

    [FPLibrary uploadLocalURLToFilepicker:tempURL
                                    named:representation.filename
                               ofMimetype:mimetype
                             shouldUpload:shouldUpload
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
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
        NSLog(@"Not Uploading");

        NSError *error = [NSError errorWithDomain:@"io.filepicker"
                                             code:200
                                         userInfo:nil];
        failure(error, nil);

        return;
    }

    size_t fileSize = [FPUtils fileSizeForLocalURL:localURL];

    if (fileSize <= fpMaxChunkSize)
    {
        NSLog(@"Uploading singlepart");

        [FPLibrary singlepartUploadWithLocalURL:localURL
                                          named:filename
                                     ofMimetype:mimetype
                                        success:success
                                        failure:failure
                                       progress:progress];
    }
    else
    {
        NSLog(@"Uploading Multipart");

        [FPLibrary multipartUploadWithLocalURL:localURL
                                         named:filename
                                    ofMimetype:mimetype
                                       success:success
                                       failure:failure
                                      progress:progress];
    }
}

+ (void)singlepartUploadWithLocalURL:(NSURL *)localURL
                               named:(NSString *)filename
                          ofMimetype:(NSString *)mimetype
                             success:(FPUploadAssetSuccessBlock)success
                             failure:(FPUploadAssetFailureBlock)failure
                            progress:(FPUploadAssetProgressBlock)progress
{
    NSDictionary *params = @{
        @"js_session":[FPUtils JSONSessionStringForAPIKey:fpAPIKEY
                                             andMimetypes:nil]
    };

    AFConstructingBodyBlock constructingBodyBlock = ^(id <AFMultipartFormData>formData) {
        NSData *filedata = [NSData dataWithContentsOfURL:localURL];

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
        if (progress && totalBytesExpectedToWrite > 0)
        {
            progress(1.0f * totalBytesWritten / totalBytesExpectedToWrite);
        }
    }];
}

+ (void)multipartUploadWithLocalURL:(NSURL *)localURL
                              named:(NSString *)filename
                         ofMimetype:(NSString *)mimetype
                            success:(FPUploadAssetSuccessBlock)success
                            failure:(FPUploadAssetFailureBlock)failure
                           progress:(FPUploadAssetProgressBlock)progress
{
    FPMultipartUpload *multipartUpload = [[FPMultipartUpload alloc] initWithLocalURL:localURL
                                                                            filename:filename
                                                                         andMimetype:mimetype];

    multipartUpload.successBlock = success;
    multipartUpload.failureBlock = failure;
    multipartUpload.progressBlock = progress;

    [multipartUpload upload];
}

@end
