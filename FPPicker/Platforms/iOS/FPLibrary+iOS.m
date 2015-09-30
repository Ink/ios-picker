//
//  FPLibrary+iOS.m
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#define FPLibrary_protected

#import "FPLibrary+iOS.h"
#import "FPInternalHeaders.h"

@import Photos;

@implementation FPLibrary (iOS)

#pragma mark - Camera Upload Methods

+ (void)    uploadImage:(UIImage *)image
             ofMimetype:(NSString *)mimetype
    usingOperationQueue:(NSOperationQueue *)operationQueue
                success:(FPUploadAssetSuccessWithLocalURLBlock)success
                failure:(FPUploadAssetFailureWithLocalURLBlock)failure
               progress:(FPUploadAssetProgressBlock)progress
{
    DONT_BLOCK_UI();

    NSString *filename;
    NSData *filedata;

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
                      usingOperationQueue:operationQueue
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
}

+ (void) uploadVideoURL:(NSURL *)url
    usingOperationQueue:(NSOperationQueue *)operationQueue
                success:(FPUploadAssetSuccessWithLocalURLBlock)success
                failure:(FPUploadAssetFailureWithLocalURLBlock)failure
               progress:(FPUploadAssetProgressBlock)progress
{
    DONT_BLOCK_UI();

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
                      usingOperationQueue:operationQueue
                                  success:successBlock
                                  failure:failureBlock
                                 progress:progress];
}

#pragma mark - Local Source Upload Methods

+ (void)    uploadAsset:(PHAsset *)asset
    usingOperationQueue:(NSOperationQueue *)operationQueue
                success:(FPUploadAssetSuccessWithLocalURLBlock)success
                failure:(FPUploadAssetFailureWithLocalURLBlock)failure
               progress:(FPUploadAssetProgressBlock)progress
{
    DONT_BLOCK_UI();

    NSURL *tempURL = [FPUtils genRandTemporaryURLWithFileLength:20];
    NSString *filename = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *mimetype = [FPUtils mimetypeForUTI:[asset valueForKey:@"uniformTypeIdentifier"]];

    NSArray<PHAssetResource *> *assetResources = [PHAssetResource assetResourcesForAsset:asset];

    if (assetResources.count > 0)
    {
        PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];

        options.networkAccessAllowed = YES;

        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:assetResources[0]
                                                                    toFile:tempURL
                                                                   options:options
                                                         completionHandler: ^(NSError * _Nullable error) {
            if (!error)
            {
                FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
                    success(JSON, tempURL);
                };

                FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
                    NSForceLog(@"File upload failed with %@, response was: %@", error, JSON);

                    failure(error, JSON, tempURL);
                };

                [FPLibrary uploadLocalURLToFilepicker:tempURL
                                                named:filename
                                           ofMimetype:mimetype
                                  usingOperationQueue:operationQueue
                                              success:successBlock
                                              failure:failureBlock
                                             progress:progress];
            }
            else
            {
                NSForceLog(@"ERROR: Unable to write image data into temporary URL at %@", tempURL);
            }
        }
        ];
    }
    else
    {
        NSForceLog(@"ERROR: Unable to obtain PHAssetResource from PHAsset.");
    }
}

@end
