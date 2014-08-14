//
//  FPSession.h
//  FPPicker
//
//  Created by Ruben Nine on 14/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPSession : NSObject

/**
   Returns a JSON representation of the session as a NSString
   @return A NSString
 */
- (NSString *)JSONSessionString;

/**
   Filepicker.io API key.
 */
@property (nonatomic, strong) NSString *APIKey;

/**
   Supported mimetype or array of mimetypes.
 */
@property (nonatomic, strong) id mimetypes;

/**
   Indicates that the file should be stored in a way that allows public access
   going directly to the underlying file store.

   Defaults to 'private'.
 */
@property (nonatomic, strong) NSString *storeAccess;

/**
   Where to store the file.

   Defaults to 'S3'.

   Other options are 'azure', 'dropbox' and 'rackspace'.
 */
@property (nonatomic, strong) NSString *storeLocation;

/**
   The path to store the file at within the specified file store.
   For S3, this is the key where the file will be stored at.
   For S3, please remember adding a trailing slash (i.e. my-custom-path/)
 */
@property (nonatomic, strong) NSString *storePath;

/**
   The bucket or container in the specified file store where the file should end up.
 */
@property (nonatomic, strong) NSString *storeContainer;

/**
   Filepicker.io security policy.
   @note Required when security is enabled.
 */
@property (nonatomic, strong) NSString *securityPolicy;

/**
   Filepicker.io security signature.
   @note Required when security is enabled.
 */
@property (nonatomic, strong) NSString *securitySignature;

@end
