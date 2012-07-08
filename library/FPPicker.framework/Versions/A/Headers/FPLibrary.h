//
//  FPLibrary.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFNetworking.h"
#import "FP_MBProgressHUD.h"
#import "FPConfig.h"

@class FPPickerController;
@class FPSaveController;

@class FPSourceController;


@protocol FPPickerDelegate <NSObject>

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)FPPickerControllerDidCancel:(FPPickerController *)picker;

@end

@protocol FPSaveDelegate <NSObject>

- (void)FPSaveController:(FPSaveController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)FPSaveControllerDidCancel:(FPSaveController *)picker;

@end


@protocol FPSourcePickerDelegate <NSObject>

- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)FPSourceControllerDidCancel:(FPSourceController *)picker;

@end


@protocol FPSourceSaveDelegate <NSObject>

@property (nonatomic, strong) NSData *data;
@property (nonatomic) NSString *dataType;


- (void)FPSourceController:(FPSourceController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)FPSourceControllerDidCancel:(FPSourceController *)picker;

@end



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
