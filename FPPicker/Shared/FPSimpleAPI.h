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

@class FPSimpleAPI;
@class FPSource;

@protocol FPSimpleAPIDelegate <NSObject>

- (void)simpleAPI:(FPSimpleAPI *__nonnull)simpleAPI requiresAuthenticationForSource:(FPSource *__nonnull)source;

@end

typedef void (^FPSimpleAPIMediaListCompletionBlock)(NSArray *__nullable mediaList, NSUInteger nextPage, NSError *__nullable error);
typedef void (^FPSimpleAPIMediaCompletionBlock)(FPMediaInfo *__nullable mediaInfo, NSError *__nullable error);
typedef void (^FPSimpleAPIProgressBlock)(float progress);

NS_ASSUME_NONNULL_BEGIN
@interface FPSimpleAPI : NSObject

@property (nonatomic, weak, nullable) id<FPSimpleAPIDelegate> delegate;

+ (FPSimpleAPI *)simpleAPIWithSource:(FPSource *)source;

/*!
   Please use the designated initializer instead.
 */
- (id)init __unavailable;

/*!
    Designated initializer.
 */
- (instancetype)initWithSource:(FPSource *)source NS_DESIGNATED_INITIALIZER;

/*!
    Requests a media list at a given path asynchronously.

    Note: Results are NOT paginated. If you would prefer the results to be paginated, please use `getMediaListAtPath:startPage:success:failure:` instead.
 */
- (void)getMediaListAtPath:(NSString *)path completion:(nullable FPSimpleAPIMediaListCompletionBlock)completion;

/*!
    Requests a media list at a given path asynchronously where the results are paginated.

    Note: When there's more than one page of results, the success block will include a `nextPage` value greater than 0 that can be used as the `startPage` value for a subsequent call to this method.
 */
- (void)getMediaListAtPath:(NSString *)path startPage:(NSUInteger)startPage completion:(nullable FPSimpleAPIMediaListCompletionBlock)completion;

/*!
   Requests a media at a given path asynchronously.
 */
- (void)getMediaInfoAtPath:(NSString *)path completion:(nullable FPSimpleAPIMediaCompletionBlock)completion progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Saves some media from a local URL to a given path in the source asynchronously.
 */
- (void)saveMediaAtLocalURL:(NSURL *)localURL named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path completion:(nullable FPSimpleAPIMediaCompletionBlock)completion progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Saves some media represented by NSData to a given path in the source asynchronously.
 */
- (void)saveMediaRepresentedByData:(NSData *)data named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path completion:(nullable FPSimpleAPIMediaCompletionBlock)completion progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Saves some media represented by a FPMediaInfo to a given path in the source asynchronously.
 */
- (void)saveMediaInfo:(FPMediaInfo *)mediaInfo named:(NSString *)name atPath:(NSString *)path completion:(nullable FPSimpleAPIMediaCompletionBlock)completion progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Suspends all the requests enqueued for execution.
 */
- (void)suspendAllRequests;

/*!
   Resumes all the requests enqueued for execution.
 */
- (void)resumeAllRequests;

/*!
   Cancels all the requests enqueued for execution and those currently running.
 */
- (void)cancelAllRequests;

@end
NS_ASSUME_NONNULL_END
