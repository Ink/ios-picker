//
//  FPSource.m
//  FPPicker
//
//  Created by Liyan David Chang on 7/7/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPSource.h"

@implementation FPSource

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {\n\tname = %@\n\tidentifier = %@\n\ticon = %@\n\trootUrl = %@\n\topen_mimetypes = %@\n\tsave_mimetypes = %@\n\tmimetypes = %@\n\texternalDomains = %@\n\toverwritePossible = %@\n\trequiresAuth = %@\n}",
            super.description,
            self.name,
            self.identifier,
            self.icon,
            self.rootPath,
            self.openMimetypes,
            self.saveMimetypes,
            self.mimetypes,
            self.externalDomains,
            self.overwritePossible ? @"YES":@"NO",
            self.requiresAuth ? @"YES":@"NO"];
}

#pragma mark - NSObject Comparison Methods

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

@end
