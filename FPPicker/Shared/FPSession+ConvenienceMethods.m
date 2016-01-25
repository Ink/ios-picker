//
//  FPSession+ConvenienceMethods.m
//  FPPicker
//
//  Created by Ruben Nine on 15/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSession+ConvenienceMethods.h"
#import "FPUtils.h"
#import "FPPrivateConfig.h"

@implementation FPSession (ConvenienceMethods)

+ (instancetype)sessionForFileUploads
{
    FPSession *fpSession = [FPSession new];

    fpSession.APIKey = fpAPIKEY;

    [fpSession populateSecurityPropertiesFromConfig];
    [fpSession populateStorePropertiesFromConfig];

    return fpSession;
}

- (void)populateSecurityPropertiesFromConfig
{
    if (fpAPPSECURITYPOLICY)
    {
        NSString *securityPolicy = fpAPPSECURITYPOLICY;

        NSString *securitySignature = fpAPPSECURITYSIGNATURE;
        self.securityPolicy = securityPolicy;
        self.securitySignature = securitySignature;
    }
}

- (void)populateStorePropertiesFromConfig
{
    self.storeAccess = [FPConfig sharedInstance].storeAccess;
    self.storeContainer = [FPConfig sharedInstance].storeContainer;
    self.storeLocation = [FPConfig sharedInstance].storeLocation;
    self.storePath = [FPConfig sharedInstance].storePath;
}

@end
