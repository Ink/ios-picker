//
//  FPUtils.h
//  FPPicker
//
//  Created by Ruben Nine on 10/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIImage;
@class ALAssetRepresentation;

@interface FPUtils : NSObject

/*!
   Returns and initializes (if not already initialized) a singleton instance
   of the framework's bundle.

   @returns An NSBundle instance
 */
+ (NSBundle *)frameworkBundle;

/*!
   Returns the UTI (Universal Type Identifier) corresponding to a given mimetype.

   @returns A NSString with the UTI
 */
+ (NSString *)utiForMimetype:(NSString *)mimetype;

/*!
   Converts input string into a string safe to be embedded into a query string

   i.e.:

   - input: ?name=ståle&car="saab"

   - output: %3Fname%3Dst%C3%A5le%26car%3D%22saab%22

   @returns An URL-encoded NSString
 */
+ (NSString *)urlEncodeString:(NSString *)inputString;


/*!
   Returns whether a mimetype is an instance of another mimetype.

   @returns YES or NO
 */
+ (BOOL)mimetype:(NSString *)mimetype instanceOfMimetype:(NSString *)supermimetype;


/*!
   Returns a time-formatted string from a given time in seconds (int only).

   @returns A time-formatted NSString
 */
+ (NSString *)formatTimeInSeconds:(int)timeInSeconds;

/*!
   Returns a randomly generated string of a given length.

   @returns A randomly generated NSString
 */
+ (NSString *)genRandStringLength:(int)len;

/*!
   Returns a temporary URL with a random file name of a given length.

   @returns A randomly generated temporary NSURL
 */
+ (NSURL *)genRandTemporaryURLWithFileLength:(int)length;

/*!
   Takes an object and returns a JSON encoded NSString.

   @returns A NSString
 */
+ (NSString *)JSONEncodeObject:(id)object error:(NSError **)error;

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
   Returns the file size of a file represented by a given local URL

   @returns The file size
 */
+ (size_t)fileSizeForLocalURL:(NSURL *)url;

/*!
   Generates a policy given a handle (optional), expiry interval (required),
   and call options (optional).

   @returns A NSString with the policy
 */
+ (NSString *)policyForHandle:(NSString *)handle
               expiryInterval:(NSTimeInterval)expiryInterval
               andCallOptions:(NSArray *)callOptions;

/*!
   Returns a signature given a policy and a secret key.

   @returns A NSString with the policy signature
 */
+ (NSString *)signPolicy:(NSString *)policy
                usingKey:(NSString *)key;

/*!
   Provided that security is enabled, appends policy and signature parameters to the input
   NSString representing the FilePicker resource; otherwise it simply returns the input given.

    @returns A NSString representing a FilePicker resource (optionally with security parameters)
 */
+ (NSString *)filePickerLocationWithOptionalSecurityFor:(NSString *)filePickerLocation;

/*!
   Validates a given URL against an URL pattern.
   Includes wildcard (*) matching support (i.e. https://fp-*.app.some-provider.com)

   @returns YES when valid; NO otherwise
 */
+ (BOOL)  validateURL:(NSString *)URL
    againstURLPattern:(NSString *)URLPattern;

/*!

 */
+ (NSDictionary *)mediaInfoForMediaType:(NSString *)mediaType
                               mediaURL:(NSURL *)mediaURL
                          originalImage:(UIImage *)originalImage
                        andJSONResponse:(id)JSONResponse;

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
