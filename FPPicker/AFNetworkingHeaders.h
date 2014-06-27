//
//  AFNetworkingHeaders.h
//  FPPicker
//
//  Created by Ruben Nine on 18/06/14.
//  Copyright (c) 2014 Filepicker.io (Cloudtop Inc.). All rights reserved.
//

// This headers' main purpose is simply to be able to import AFNetworking
// and extend parts of the original AFNetworking library without directly modifying it.

#import "AFNetworking.h"

// Typedefin' commonly used blocks

typedef void (^AFRequestOperationSuccessBlock)(AFHTTPRequestOperation *operation,
                                               id responseObject);

typedef void (^AFRequestOperationFailureBlock)(AFHTTPRequestOperation *operation,
                                               NSError *error);

typedef void (^AFConstructingBodyBlock)(id <AFMultipartFormData> formData);
