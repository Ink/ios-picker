//
//  FPFileUploadController.h
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPFileTransferController.h"

@interface FPFileUploadController : FPFileTransferController

- (instancetype)initWithData:(NSData *)data
                    filename:(NSString *)filename
                  targetPath:(NSString *)path
                 andMimetype:(NSString *)mimetype;

- (instancetype)initWithDataURL:(NSURL *)dataURL
                       filename:(NSString *)filename
                     targetPath:(NSString *)path
                    andMimetype:(NSString *)mimetype;

@end
