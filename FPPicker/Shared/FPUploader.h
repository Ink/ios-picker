//
//  FPUploader.h
//  FPPicker
//
//  Created by Ruben Nine on 16/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPInternalHeaders.h"

@interface FPUploader : NSObject

/**
   Please use the designated initializer instead.
 */
- (id)init __unavailable;

/**
   Designated initializer.

   Expects a local URL representing the file to upload, a filename and a mimetype.
 */
- (instancetype)initWithLocalURL:(NSURL *)localURL
                        filename:(NSString *)filename
                        mimetype:(NSString *)mimetype
               andOperationQueue:(NSOperationQueue *)operationQueue NS_DESIGNATED_INITIALIZER;

/**
   Initiates the file upload.

   @note Once the upload has completed, calling this method again will result in a no-op.
 */
- (void)upload;

/**
   Block to call after an upload succeeds without errors.

   This block returns a JSON response object.

   @note If no block is provided, a default implementation is used
   which simply logs the JSON response to the console.
 */
@property (nonatomic, copy) FPUploadAssetSuccessBlock successBlock;

/**
   Block to call after an upload fails.

   This block returns an NSError and a JSON response object (when available)

   @note If no block is provided, a default implementation is used
   failing with an assert displaying the NSError description on the console.
 */
@property (nonatomic, copy) FPUploadAssetFailureBlock failureBlock;

/**
   Block to call everytime the upload progress is updated.

   This block returns a float with the progress (range: 0.0 to 1.0)

   @note Optional.
 */
@property (nonatomic, copy) FPUploadAssetProgressBlock progressBlock;

/**
    The operation queue to use to perform uploads.

    @note Optional.
 */
@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;

#ifdef FPUploader_protected

- (void)setup;
- (void)doUpload;

@property (nonatomic, assign) BOOL hasFinished;
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *mimetype;
@property (nonatomic, strong) NSString *js_sessionString;

#endif

@end
