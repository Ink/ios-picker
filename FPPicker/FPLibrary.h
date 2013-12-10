//
//  FPLibrary.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FPLibrary : NSObject

//For the camera
+ (void) uploadImage:(UIImage*)image
          ofMimetype:(NSString*)mimetype
         withOptions:(NSDictionary*)options
        shouldUpload:(BOOL) shouldUpload
             success:(void (^)(id JSON, NSURL *localurl))success 
             failure:(void (^)(NSError *error, id JSON, NSURL *localurl))failure
            progress:(void (^)(float progress))progress;

+ (void) uploadVideoURL: (NSURL*) url
            withOptions:(NSDictionary*)options
           shouldUpload:(BOOL) shouldUpload
                success:(void (^)(id JSON, NSURL *localurl))success 
                failure:(void (^)(NSError *error, id JSON, NSURL *localurl))failure
               progress:(void (^)(float progress))progress;

//For uploading local images on open (Camera roll)
+ (void) uploadAsset:(ALAsset*)asset
         withOptions:(NSDictionary*)options
        shouldUpload:(BOOL) shouldUpload
             success:(void (^)(id JSON, NSURL *localurl))success
             failure:(void (^)(NSError *error, id JSON, NSURL *localurl))failure
            progress:(void (^)(float progress))progress;

//For saveas
+ (void) uploadData:(NSData*)filedata
              named: (NSString *)filename
             toPath: (NSString*)path
               ofMimetype: (NSString*)mimetype
         withOptions:(NSDictionary*)options 
             success:(void (^)(id JSON))success 
             failure:(void (^)(NSError *error, id JSON))failure
           progress:(void (^)(float progress))progress;

+ (void) uploadDataURL:(NSURL*)filedataurl
                 named: (NSString *)filename
                toPath: (NSString*)path
            ofMimetype: (NSString*)mimetype
           withOptions:(NSDictionary*)options
               success:(void (^)(id JSON))success
               failure:(void (^)(NSError *error, id JSON))failure
              progress:(void (^)(float progress))progress;

+(NSString*)urlEscapeString:(NSString *)unencodedString;
+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;

+ (NSBundle *)frameworkBundle;

+ (id) JSONObjectWithData:(NSData *)data;
+ (NSData *) dataWithJSONObject:(id)object;

+ (BOOL) mimetype:(NSString *)mimetype instanceOfMimetype:(NSString *)supermimetype;

+ (NSString *) formatTimeInSeconds: (int) timeInSeconds;

+ (NSString *) genRandStringLength: (int) len;

@end
