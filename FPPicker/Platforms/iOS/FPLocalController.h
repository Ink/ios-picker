//
//  FPLocalController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FPPicker.h"
#import "FPInternalHeaders.h"
#import "FPTableWithUploadButtonViewController.h"

typedef void (^FPLocalUploadAssetSuccessBlock)(NSDictionary *data);
typedef void (^FPLocalUploadAssetFailureBlock)(NSError *error, NSDictionary *data);
typedef void (^FPLocalUploadAssetProgressBlock)(float progress);

@interface FPLocalController : FPTableWithUploadButtonViewController

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, weak) id <FPSourcePickerDelegate> fpdelegate;
@property (nonatomic, retain) ALAssetsGroup *assetGroup;

@end
