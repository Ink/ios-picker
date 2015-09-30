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

    @returns void
 */
+ (void)asyncFetchAssetThumbnailFromPHAsset:(PHAsset *)asset
                                 completion:(FPFetchPHAssetImageBlock)completionBlock;

@end
