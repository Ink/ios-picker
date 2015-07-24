//
//  FPSimpleAPI.h
//  FPPicker
//
//  NOTE: This API is in development and not yet ready to be used.
//
//  Created by Ruben Nine on 7/21/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

@import Foundation;
#import "FPExternalHeaders.h"

typedef void (^FPSimpleAPIGetMediaListSuccessBlock)(NSArray *mediaList);
typedef void (^FPSimpleAPIGetMediaSuccessBlock)(FPMediaInfo *mediaInfo);
typedef void (^FPSimpleAPISuccessBlock)();
typedef void (^FPSimpleAPIFailureBlock)(NSError *error);
typedef void (^FPSimpleAPIProgressBlock)(float progress);

@interface FPSimpleAPI : NSObject

@property (nonatomic, weak) id<FPSimpleAPIDelegate> delegate;

/*!
   Please use the designated initializer instead.
 */
- (id)init __unavailable;

/*!
    Designated initializer.
 */
- (instancetype)initWithSource:(FPSource *)source NS_DESIGNATED_INITIALIZER;

/*!
    Asynchronously requests a list of media at a given path.
 */
- (void)getMediaListAtPath:(NSString *)path success:(FPSimpleAPIGetMediaListSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure;

/*!
   Asynchronously requests a media at a given path.
 */
- (void)getMediaInfoAtPath:(NSString *)path success:(FPSimpleAPIGetMediaSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress;

/*!
   Asynchronously saves some media from a local URL to an existing path in the source.
 */
- (void)saveMediaAtLocalURL:(NSURL *)localURL named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(FPSimpleAPISuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress;

/*!
   Asynchronously saves some media represented as NSData to an existing path in the source.
 */
- (void)saveMediaRepresentedByData:(NSData *)data named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(FPSimpleAPISuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress;

/*!
   Cancels any pending requests.
 */
- (void)cancelPendingRequests;

@end
