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
- (instancetype)initWithSource:(nonnull FPSource *)source NS_DESIGNATED_INITIALIZER;

/*!
    Requests a media list at a given path asynchronously.
 */
- (void)getMediaListAtPath:(nonnull NSString *)path success:(nullable FPSimpleAPIGetMediaListSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure;

/*!
   Requests a media at a given path asynchronously.
 */
- (void)getMediaInfoAtPath:(nonnull NSString *)path success:(nullable FPSimpleAPIGetMediaSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Saves some media from a local URL to a given path in the source asynchronously.
 */
- (void)saveMediaAtLocalURL:(nonnull NSURL *)localURL named:(nonnull NSString *)name withMimeType:(nonnull NSString *)mimetype atPath:(nonnull NSString *)path success:(nullable FPSimpleAPISuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Saves some media represented as NSData to a given path in the source asynchronously.
 */
- (void)saveMediaRepresentedByData:(nonnull NSData *)data named:(nonnull NSString *)name withMimeType:(nonnull NSString *)mimetype atPath:(nonnull NSString *)path success:(nullable FPSimpleAPISuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Cancels all the requests in the queue including those that are currently in progress.
 */
- (void)cancelAllRequests;

@end
