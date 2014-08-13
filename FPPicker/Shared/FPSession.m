//
//  FPSession.m
//  FPPicker
//
//  Created by Ruben Nine on 14/07/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPSession.h"
#import "FPUtils.h"

@implementation FPSession

- (NSString *)JSONSessionString
{
    NSError *error;

    NSMutableDictionary *sessionObject = [@{@"app":[@{} mutableCopy]} mutableCopy];

    if (self.APIKey)
    {
        sessionObject[@"app"][@"apikey"] = self.APIKey;
    }

    if (self.mimetypes)
    {
        sessionObject[@"mimetypes"] = self.mimetypes;
    }

    if (self.storeAccess)
    {
        sessionObject[@"storeAccess"] = self.storeAccess;
    }

    if (self.storeLocation)
    {
        sessionObject[@"storeLocation"] = self.storeLocation;
    }

    if (self.storePath)
    {
        sessionObject[@"storePath"] = self.storePath;
    }

    if (self.storeContainer)
    {
        sessionObject[@"storeContainer"] = self.storeContainer;
    }

    if (self.securityPolicy)
    {
        sessionObject[@"policy"] = self.securityPolicy;
    }

    if (self.securitySignature)
    {
        sessionObject[@"signature"] = self.securitySignature;
    }

    return [FPUtils JSONEncodeObject:sessionObject
                               error:&error];
}

@end
