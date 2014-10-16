//
//  FPLibrary+iOS.h
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPLibrary.h"

@class ALAsset;

@interface FPLibrary (iOS)

// For the camera

+ (void)uploadImage:(UIImage *)image
         ofMimetype:(NSString *)mimetype
        withOptions:(NSDictionary *)options
       shouldUpload:(BOOL)shouldUpload
            success:(FPUploadAssetSuccessWithLocalURLBlock)success
            failure:(FPUploadAssetFailureWithLocalURLBlock)failure
           progress:(FPUploadAssetProgressBlock)progress;

+ (void)uploadVideoURL:(NSURL *)url
           withOptions:(NSDictionary *)options
          shouldUpload:(BOOL)shouldUpload
               success:(FPUploadAssetSuccessWithLocalURLBlock)success
               failure:(FPUploadAssetFailureWithLocalURLBlock)failure
              progress:(FPUploadAssetProgressBlock)progress;

// For uploading local images on open (Camera roll)

+ (void)uploadAsset:(ALAsset *)asset
        withOptions:(NSDictionary *)options
       shouldUpload:(BOOL)shouldUpload
            success:(FPUploadAssetSuccessWithLocalURLBlock)success
            failure:(FPUploadAssetFailureWithLocalURLBlock)failure
           progress:(FPUploadAssetProgressBlock)progress;

@end
