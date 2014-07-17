//
//  FPSource.m
//  FPPicker
//
//  Created by Liyan David Chang on 7/7/12.
//  Copyright (c) 2012 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPSource.h"

@implementation FPSource

- (NSString *)mimetypeString
{
    if (self.mimetypes.count == 0)
    {
        return @"[]";
    }

    return [NSString stringWithFormat:@"[\"%@\"]", [self.mimetypes componentsJoinedByString:@"\",\""]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {name: %@, identifier: %@, icon: %@, rootUrl: %@, open_mimetypes: %@, save_mimetypes: %@, mimetypes: %@, externalDomains: %@, overwritePossible: %d}",
            super.description,
            self.name,
            self.identifier,
            self.icon,
            self.rootUrl,
            self.open_mimetypes,
            self.save_mimetypes,
            self.mimetypes,
            self.externalDomains,
            self.overwritePossible];
}

@end
