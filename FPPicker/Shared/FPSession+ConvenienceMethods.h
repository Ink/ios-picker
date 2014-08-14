//
//  FPSession+ConvenienceMethods.h
//  FPPicker
//
//  Created by Ruben Nine on 15/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSession.h"

@interface FPSession (ConvenienceMethods)

/**
   Returns a session object suited for file uploads
   with API key and security options already initialized.
 */
+ (instancetype)sessionForFileUploads;

/**
   Populates the FPSession object security properties with values
   obtained from FPConfig.
 */
- (void)populateSecurityPropertiesFromConfig;

/**
   Populates the FPSession object store properties with values
   obtained from FPConfig.
 */
- (void)populateStorePropertiesFromConfig;

@end
