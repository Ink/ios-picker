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
    NSString *defaultFilename = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *mimetype = [FPUtils mimetypeForUTI:[asset valueForKey:@"uniformTypeIdentifier"]];

    PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
    imageRequestOptions.networkAccessAllowed = YES;

    // #103: The PHAssetResource class is available on iOS 9 and later, so we
    // must use PHImageManager to support iOS 8
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:imageRequestOptions
                                                resultHandler:^(NSData * _Nullable imageData,
                                                                NSString * _Nullable dataUTI,
                                                                UIImageOrientation orientation,
                                                                NSDictionary * _Nullable info)
    {
         // It's not clear how requestImageDataForAsset will manifest a failure, so try a couple different checks
         if (!imageData || imageData.bytes == 0) {
             NSError *error = [[NSError alloc] initWithDomain:@"FPPicker"
                                                         code:-10 // this is an arbitrary value
                                                     userInfo:@{@"filePickerMessage": @"ERROR: Unable to obtain PHAssetResource from PHAsset."}];
             if (failure) {
                 failure(error, nil, tempURL);
             }
             return;
         }

         BOOL result = [imageData writeToURL:tempURL atomically:YES];
         if (!result) {
             NSString *message = [NSString stringWithFormat:@"ERROR: Unable to write image data into temporary URL at %@", tempURL];
             NSError *error = [[NSError alloc] initWithDomain:@"FPPicker"
                                                         code:-11 // this is an arbitrary value
                                                     userInfo:@{@"filePickerMessage": message}];
             if (failure) {
                 failure(error, nil, tempURL);
             }
             return;
         }

         FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
             success(JSON, tempURL);
         };

         FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
             NSForceLog(@"File upload failed with %@, response was: %@", error, JSON);

             if (failure) {
                 failure(error, JSON, tempURL);
             }
         };

         NSString *filePath = info[@"PHImageFileURLKey"];
         NSString *filename;
         if (filePath) {
             filename = [filePath lastPathComponent];
         } else {
             filename = defaultFilename;
         }

         [FPLibrary uploadLocalURLToFilepicker:tempURL
                                         named:filename
                                    ofMimetype:mimetype
                           usingOperationQueue:operationQueue
                                       success:successBlock
                                       failure:failureBlock
                                      progress:progress];
    }];
}

@end
