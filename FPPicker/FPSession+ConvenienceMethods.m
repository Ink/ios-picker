//
//  FPSession+ConvenienceMethods.m
//  FPPicker
//
//  Created by Ruben Nine on 15/07/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPSession+ConvenienceMethods.h"
#import "FPUtils.h"
#import "FPConfig.h"

@implementation FPSession (ConvenienceMethods)

+ (instancetype)sessionForFileUploads
{
    FPSession *fpSession = [FPSession new];

    fpSession.APIKey = fpAPIKEY;

    if (fpAPPSECRETKEY)
    {
        NSString *securityPolicy = [FPUtils policyForHandle:nil
                                             expiryInterval:3600.0
                                             andCallOptions:nil];

        NSString *securitySignature = [FPUtils signPolicy:securityPolicy
                                                 usingKey:fpAPPSECRETKEY];

        fpSession.securityPolicy = securityPolicy;
        fpSession.securitySignature = securitySignature;
    }

    [fpSession populateStorePropertiesFromConfig];

    return fpSession;
}

- (void)populateStorePropertiesFromConfig
{
    self.storeAccess = [FPConfig sharedInstance].storeAccess;
    self.storeContainer = [FPConfig sharedInstance].storeContainer;
    self.storeLocation = [FPConfig sharedInstance].storeLocation;
    self.storePath = [FPConfig sharedInstance].storePath;
}

@end
