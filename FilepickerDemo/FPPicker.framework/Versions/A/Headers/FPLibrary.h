//
//  FPLibrary.h
//  filepicker
//
//  Created by Liyan David Chang on 6/28/12.
//  Copyright (c) 2012 Filepicker.io, All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "FP_MBProgressHUD.h"
#import "FPConfig.h"

@class FPPickerController;
@class FPSourceController;


@protocol FPPickerDelegate <NSObject>

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)FPPickerControllerDidCancel:(FPPickerController *)picker;

@end

@protocol FPSourcePickerDelegate <NSObject>

- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)FPSourceControllerDidCancel:(FPSourceController *)picker;

@end


@interface FPLibrary : NSObject

+ (void) uploadImage:(UIImage*)image 
         withOptions:(NSDictionary*)options 
         success:(void (^)(id JSON))success 
         failure:(void (^)(NSError *error, id JSON))failure;

+(NSString*)urlEscapeString:(NSString *)unencodedString;
+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;

+ (NSBundle *)frameworkBundle;

+ (id) JSONObjectWithData:(NSData *)data;
+ (NSData *) dataWithJSONObject:(id)object;

@end
