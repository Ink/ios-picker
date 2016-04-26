//
//  FPConfig.h
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, FPLogLevel) {
    FPInfoLogLevel,
    FPErrorLogLevel,
};

typedef void (^FPVideoUploadPreprocessorBlock)(NSURL *localURL);
typedef void (^FPImageUploadPreprocessorBlock)(NSURL *localURL, NSString *mimetype);
typedef void (^FPLoggingBlock)(NSString *message, FPLogLevel logLevel);

@interface FPConfig : NSObject

/*!
   Filepicker.io base URL (read-only.)
 */
@property (nonatomic, readonly, strong) NSURL *baseURL;

/*!
   Filepicker.io API key (required.)
 */
@property (nonatomic, strong) NSString *APIKey;

/*!
   Filepicker.io App secret key (required if security is enabled in Developer Portal)
 */
@property (nonatomic, strong) NSString *appSecretKey;

/*!
   Indicates that the file should be stored in a way that allows public access
   going directly to the underlying file store.

   Defaults to 'private'.
 */
@property (nonatomic, strong) NSString *storeAccess;

/*!
   Where to store the file.

   Defaults to 'S3'.

   Other options are 'azure', 'dropbox' and 'rackspace'.
 */
@property (nonatomic, strong) NSString *storeLocation;

/*!
   The path to store the file at within the specified file store.
   For S3, this is the key where the file will be stored at.
   For S3, please remember adding a trailing slash (i.e. my-custom-path/)
 */
@property (nonatomic, strong) NSString *storePath;

/*!
   The bucket or container in the specified file store where the file should end up.
 */
@property (nonatomic, strong) NSString *storeContainer;

/*!
   User-definable video upload preprocessor block.
 */
@property (nonatomic, copy) FPVideoUploadPreprocessorBlock videoUploadPreprocessorBlock;

/*!
   User-definable image upload preprocessor block.
 */
@property (nonatomic, copy) FPImageUploadPreprocessorBlock imageUploadPreprocessorBlock;

/*!
 User-definable block so the host application can be aware of errors within the FP library.
 The library will log to the console if loggingBlock is nil.
 */
@property (nonatomic, copy) FPLoggingBlock loggingBlock;

/*!
   Returns a singleton FPConfig instance.
 */
+ (instancetype)sharedInstance;

/*!
 Emit a log message to the console or invoke the logging block.
 */
+ (void)logMessage:(NSString *)message logLevel:(FPLogLevel)logLevel;

@end
