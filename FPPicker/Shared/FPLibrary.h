//
//  FPLibrary.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPTypedefs.h"

@interface FPLibrary : NSObject

+ (void)uploadData:(NSData*)filedata
             named:(NSString *)filename
            toPath:(NSString*)path
        ofMimetype:(NSString*)mimetype
       withOptions:(NSDictionary*)options
           success:(FPUploadAssetSuccessBlock)success
           failure:(FPUploadAssetFailureBlock)failure
          progress:(FPUploadAssetProgressBlock)progress;

+ (void)uploadDataURL:(NSURL*)filedataurl
                named:(NSString *)filename
               toPath:(NSString*)path
           ofMimetype:(NSString*)mimetype
          withOptions:(NSDictionary*)options
              success:(FPUploadAssetSuccessBlock)success
              failure:(FPUploadAssetFailureBlock)failure
             progress:(FPUploadAssetProgressBlock)progress;

@end
