//
//  FPLibrary+iOS.m
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPLibrary+iOS.h"
#import "FPInternalHeaders.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FPLibrary ()

+ (dispatch_queue_t)upload_processing_queue;

+ (void)uploadDataHelper_saveAs:(NSString *)fileLocation
                         toPath:(NSString *)saveLocation
                     ofMimetype:(NSString *)mimetype
                    withOptions:(NSDictionary *)options
                        success:(FPUploadAssetSuccessBlock)success
                        failure:(FPUploadAssetFailureBlock)failure;

+ (void)uploadLocalURLToFilepicker:(NSURL *)localURL
                             named:(NSString *)filename
                        ofMimetype:(NSString *)mimetype
                      shouldUpload:(BOOL)shouldUpload
                           success:(FPUploadAssetSuccessBlock)success
                           failure:(FPUploadAssetFailureBlock)failure
                          progress:(FPUploadAssetProgressBlock)progress;

@end

@implementation FPLibrary (iOS)

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

@end
