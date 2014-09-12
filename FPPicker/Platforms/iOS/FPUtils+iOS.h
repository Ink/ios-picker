//
//  FPUtils+iOS.h
//  FPPicker
//
//  Created by Ruben Nine on 13/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils.h"
#import <UIKit/UIKit.h>

@class ALAssetRepresentation;

@interface FPUtils (iOS)

/*!
   Returns the UTI (Universal Type Identifier) corresponding to a given mimetype.

   @returns A NSString with the UTI
 */
+ (NSString *)utiForMimetype:(NSString *)mimetype;

/*!
   Performs a copy in chunks from a given ALAssetRepresentation into a local URL.

   @notes

   - Chunk size equals to fpMaxLocalChunkCopySize (~2mb)
   - By ALAssetRepresentation we mean the "best" or original size representation of an asset.

   @returns YES on success; NO otherwise
 */
+ (BOOL)copyAssetRepresentation:(ALAssetRepresentation *)representation
                   intoLocalURL:(NSURL *)localURL;

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

@end
