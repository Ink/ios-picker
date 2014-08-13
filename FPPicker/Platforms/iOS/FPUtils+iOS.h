//
//  FPUtils+iOS.h
//  FPPicker
//
//  Created by Ruben Nine on 13/08/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPUtils.h"

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

 */
+ (NSDictionary *)mediaInfoForMediaType:(NSString *)mediaType
                               mediaURL:(NSURL *)mediaURL
                          originalImage:(UIImage *)originalImage
                        andJSONResponse:(id)JSONResponse;

@end
