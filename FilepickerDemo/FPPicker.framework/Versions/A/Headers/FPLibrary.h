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

@interface FPLibrary : NSObject

//For uploading local images on open
+ (void) uploadImage:(UIImage*)image 
         withOptions:(NSDictionary*)options 
         success:(void (^)(id JSON))success 
         failure:(void (^)(NSError *error, id JSON))failure;

//For saveas
+ (void) uploadData:(NSData*)data
              named: (NSString *)filename
             toPath: (NSString*)path
               type: (NSString*)type
         withOptions:(NSDictionary*)options 
             success:(void (^)(id JSON))success 
             failure:(void (^)(NSError *error, id JSON))failure;


+(NSString*)urlEscapeString:(NSString *)unencodedString;
+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;

+ (NSBundle *)frameworkBundle;

+ (id) JSONObjectWithData:(NSData *)data;
+ (NSData *) dataWithJSONObject:(id)object;

@end
