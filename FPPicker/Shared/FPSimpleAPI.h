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

typedef void (^FPSimpleAPIGetMediaListSuccessBlock)(NSArray *__nonnull mediaList, NSUInteger nextPage);
typedef void (^FPSimpleAPIGetMediaSuccessBlock)(FPMediaInfo *__nonnull mediaInfo);
typedef void (^FPSimpleAPISuccessBlock)();
typedef void (^FPSimpleAPIFailureBlock)(NSError *__nonnull error);
typedef void (^FPSimpleAPIProgressBlock)(float progress);

NS_ASSUME_NONNULL_BEGIN
@interface FPSimpleAPI : NSObject

@property (nonatomic, weak, nullable) id<FPSimpleAPIDelegate> delegate;

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
- (void)getMediaListAtPath:(NSString *)path success:(nullable FPSimpleAPIGetMediaListSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure;

/*!
    Requests a media list at a given path asynchronously where the results are paginated.

    Note: When there's more than one page of results, the success block will include a `nextPage` value greater than 0 that can be used as the `startPage` value for a subsequent call to this method.
 */
- (void)getMediaListAtPath:(NSString *)path startPage:(NSUInteger)startPage success:(nullable FPSimpleAPIGetMediaListSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure;

/*!
   Requests a media at a given path asynchronously.
 */
- (void)getMediaInfoAtPath:(NSString *)path success:(nullable FPSimpleAPIGetMediaSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Saves some media from a local URL to a given path in the source asynchronously.
 */
- (void)saveMediaAtLocalURL:(NSURL *)localURL named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(nullable FPSimpleAPISuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Saves some media represented by NSData to a given path in the source asynchronously.
 */
- (void)saveMediaRepresentedByData:(NSData *)data named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(nullable FPSimpleAPISuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress;

/*!
   Cancels all the requests in the queue including those that are currently in progress.
 */
- (void)cancelAllRequests;

@end
NS_ASSUME_NONNULL_END
