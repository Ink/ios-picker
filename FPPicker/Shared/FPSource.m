//
//  FPSource.m
//  FPPicker
//
//  Created by Liyan David Chang on 7/7/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPSource.h"
#import "FPUtils.h"

@implementation FPSource

- (NSString *)fullSourcePathForRelativePath:(NSString *)relativePath
{
    NSString *tmpPath = [relativePath copy];

    if ([tmpPath characterAtIndex:0] == 47) // remove trailing slash, if present
    {
        tmpPath = [tmpPath substringFromIndex:1];
    }

    if (tmpPath.length > 0 &&
        [tmpPath characterAtIndex:tmpPath.length - 1] == 47) // remove leading slash, if present
    {
        tmpPath = [tmpPath substringToIndex:tmpPath.length - 1];
    }

    NSString *sanitizedRelativePath = [FPUtils urlEncodeString:tmpPath];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/", self.rootPath, sanitizedRelativePath];

    return fullPath;
}

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
            self.overwritePossible ? @"YES" : @"NO",
            self.requiresAuth ? @"YES" : @"NO"];
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
