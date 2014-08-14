//
//  FPTypedefs.h
//  FPPicker
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

typedef void (^FPUploadAssetSuccessBlock)(id JSON);
typedef void (^FPUploadAssetFailureBlock)(NSError *error, id JSON);
typedef void (^FPUploadAssetProgressBlock)(float progress);
typedef void (^FPUploadAssetSuccessWithLocalURLBlock)(id JSON, NSURL *localurl);
typedef void (^FPUploadAssetFailureWithLocalURLBlock)(NSError *error, id JSON, NSURL *localurl);
