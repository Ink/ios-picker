//
//  FPMultipartUpload.h
//  FPPicker
//
//  Created by Ruben Nine on 25/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPInternalHeaders.h"

@interface FPMultipartUpload : NSObject

@property (nonatomic, copy) FPUploadAssetSuccessBlock successBlock;
@property (nonatomic, copy) FPUploadAssetFailureBlock failureBlock;
@property (nonatomic, copy) FPUploadAssetProgressBlock progressBlock;

- (instancetype)initWithLocalURL:(NSURL *)localURL
                        filename:(NSString *)filename
                     andMimetype:(NSString *)mimetype;

- (void)upload;

@end
