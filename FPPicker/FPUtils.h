//
//  FPUtils.h
//  FPPicker
//
//  Created by Ruben Nine on 10/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface FPUtils : NSObject

/**
   Returns and initializes (if not already initialized) a singleton instance
   of the framework's bundle.

   @returns An NSBundle instance
 */
+ (NSBundle *)frameworkBundle;

/**
   Returns the UTI (Universal Type Identifier) corresponding to a given mimetype.

   @returns A NSString with the UTI
 */
+ (NSString *)utiForMimetype:(NSString *)mimetype;

/**
   Converts input string into a string safe to be embedded into a query string

   i.e.:

   - input: http://my test.org?name=ståle&car="saab"

   - output: http%3A%2F%2Fmy%20test.org%3Fname%3Dst%C3%A5le%26car%3D%22saab%22

   @returns An URL-encoded NSString
 */
+ (NSString *)urlEncodeString:(NSString *)inputString;


/**
   Returns whether a mimetype is an instance of another mimetype.

   @returns YES or NOT
 */
+ (BOOL)mimetype:(NSString *)mimetype instanceOfMimetype:(NSString *)supermimetype;


/**
   Returns a time-formatted string from a given time in seconds (int only).

   @returns A time-formatted NSString
 */
+ (NSString *)formatTimeInSeconds:(int)timeInSeconds;

/**
   Returns a randomly generated string of a given length.

   @returns A randomly generated NSString
 */
+ (NSString *)genRandStringLength:(int)len;

/**
   Returns an image with corrected rotation.

   @returns An UIImage
 */
+ (UIImage *)fixImageRotationIfNecessary:(UIImage *)image;

@end
