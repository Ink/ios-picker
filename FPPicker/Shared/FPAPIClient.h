//
//  FPAPIClient.h
//  FPPicker
//
//  Created by Ruben Nine on 18/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface FPAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
