//
//  FPTypedefs.h
//  FPPicker
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

@class AFHTTPRequestOperation;
@protocol AFMultipartFormData;

@class FPMediaInfo;

typedef void (^FPUploadAssetSuccessBlock)(id JSON);

typedef void (^FPUploadAssetFailureBlock)(NSError *error,
                                          id JSON);

typedef void (^FPUploadAssetProgressBlock)(float progress);

typedef void (^FPUploadAssetSuccessWithLocalURLBlock)(id JSON,
                                                      NSURL *localURL);

typedef void (^FPUploadAssetFailureWithLocalURLBlock)(NSError *error,
                                                      id JSON,
                                                      NSURL *localURL);

typedef void (^FPFetchObjectSuccessBlock)(FPMediaInfo *mediaInfo);

typedef void (^FPFetchObjectFailureBlock)(NSError *error);

typedef void (^FPFetchObjectProgressBlock)(float progress);


// AFNetworking block typedefs.

typedef void (^AFRequestOperationSuccessBlock)(AFHTTPRequestOperation *operation,
                                               id responseObject);

typedef void (^AFRequestOperationFailureBlock)(AFHTTPRequestOperation *operation,
                                               NSError *error);

typedef void (^AFConstructingBodyBlock)(id <AFMultipartFormData> formData);
