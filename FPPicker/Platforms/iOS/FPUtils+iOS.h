//
//  FPUtils+iOS.h
//  FPPicker
//
//  Created by Ruben Nine on 13/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils.h"
#import <UIKit/UIKit.h>

@class PHAsset;
@class PHImageManager;

typedef void (^FPFetchPHAssetImageBlock)(UIImage *image);

@interface FPUtils (iOS)

/*!
   Returns an image with corrected rotation.

   @returns An UIImage
 */
+ (UIImage *)fixImageRotationIfNecessary:(UIImage *)image;

/*!
   Returns a JPEG compressed image with the desired compression factor.

   @returns An UIImage
 */
+ (UIImage *)compressImage:(UIImage *)image
     withCompressionFactor:(CGFloat)compressionFactor
            andOrientation:(UIImageOrientation)orientation;

/*!
    Asynchronously fetches the thumbnail UIImage representing the given asset.
    Note: the completionBlock might be called multiple times, see documentation for
    -[PHImageManager requestImageForAsset:targetSize:contentMode:options:resultHandler:]

    @returns void
 */
+ (void)asyncFetchAssetThumbnailFromPHAsset:(PHAsset *)asset
                                 completion:(FPFetchPHAssetImageBlock)completionBlock;


/*!
    Asynchronously fetches the thumbnail UIImage representing the given asset.
    The completion block is guaranted to be called only once

    @returns void
 */
+ (void)asyncFetchAssetThumbnailFromPHAsset:(PHAsset *)asset
               ensureCompletionIsCalledOnce:(BOOL)ensureOnce
                                 completion:(FPFetchPHAssetImageBlock)completionBlock;

/*!
   Returns whether the current running app is an app extension.

   @returns YES or NO
 */
+ (BOOL)currentAppIsAppExtension;

@end
