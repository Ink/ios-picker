//
//  FPUtils.h
//  FPPicker
//
//  Created by Ruben Nine on 10/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

@import Foundation;

@interface FPUtils : NSObject

/*!
   Returns and initializes (if not already initialized) a singleton instance
   of the framework's bundle.

   @returns An NSBundle instance
 */
+ (NSBundle *)frameworkBundle;

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
   Returns the UTI (Universal Type Identifier) corresponding to a given MIME type.

   @returns A NSString with the UTI
 */
+ (NSString *)UTIForMimetype:(NSString *)mimetype;

/*!
   Returns the MIME type corresponding to a given UTI (Universal Type Identifier).

   @returns A NSString with the MIME type
 */
+ (NSString *)mimetypeForUTI:(NSString *)UTI;

/*!
   Tests for a conformance relationship between the two identified
   types. Returns true if the types are equal, or if the first type

   @returns YES when conforming; NO otherwise
 */
+ (BOOL)      UTI:(NSString *)UTI
    conformsToUTI:(NSString *)conformsToUTI;

/*!
   Returns a NSError instance with a given error code and localized error description.

   @returns A NSError
 */
+ (NSError *) errorWithCode:(NSInteger)code
    andLocalizedDescription:(NSString *)localizedDescription;

/*!
   Returns uniqe string

   @returns NSString with uniqe stirng
 */
+ (NSString *)uuidString;

@end
