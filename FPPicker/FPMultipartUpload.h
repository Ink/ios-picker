//
//  FPMultipartUpload.h
//  FPPicker
//
//  Created by Ruben Nine on 25/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPInternalHeaders.h"

@interface FPMultipartUpload : NSObject

/**
   Returns whether the file has completed uploading.

   @return YES or NO
 */
@property (readonly, assign) BOOL hasFinished;

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
    Designated initializer

    Expects a local URL representing the file to upload, a filename and a mimetype.
 */
- (instancetype)initWithLocalURL:(NSURL *)localURL
                        filename:(NSString *)filename
                     andMimetype:(NSString *)mimetype;

/**
    Initiates the file upload.

    @note Once the upload has completed, calling this method again will result in a no-op.
 */
- (void)upload;

@end
