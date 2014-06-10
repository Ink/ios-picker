//
//  FPAFNetworkingHeaders.h
//  FPPicker
//
//  Created by Ruben Nine on 10/06/14.
//  Copyright (c) 2014 Filepicker.io (Cloudtop Inc.). All rights reserved.
//

// This headers' main purpose is simply to be able to import FPAFNetworking
// and extend parts of the original FPAFNetworking library without directly modifying it.

#import "FPAFNetworking.h"

// Typedefin' commonly used blocks

typedef void (^FPARequestOperationSuccessBlock)(NSURLRequest *request,
                                                NSHTTPURLResponse *response,
                                                id JSON);

typedef void (^FPARequestOperationFailureBlock)(NSURLRequest *request,
                                                NSHTTPURLResponse *response,
                                                NSError *error,
                                                id JSON);

typedef void (^FPAFHTTPRequestOperationSuccessBlock)(FPAFHTTPRequestOperation *operation,
                                                     id responseObject);

typedef void (^FPAFHTTPRequestOperationFailureBlock)(FPAFHTTPRequestOperation *operation,
                                                     NSError *error);
