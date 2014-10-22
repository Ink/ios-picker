//
//  FPSourcePath.m
//  FPPicker
//
//  Created by Ruben Nine on 20/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSourcePath.h"
#import "FPSource.h"

@interface FPSourcePath () <NSCopying>

@end

@implementation FPSourcePath

- (instancetype)initWithSource:(FPSource *)source
                       andPath:(NSString *)path
{
    self = [super init];

    if (self)
    {
        self.source = source;
        self.path = path;
    }

    return self;
}

- (NSString *)rootPath
{
    if (!self.source)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"source must be present."];
    }

    return [self.source.rootPath stringByAppendingString:@"/"];
}

- (NSString *)parentPath
{
    if (!self.path)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"path must be present."];
    }

    if ([self.rootPath isEqualToString:self.path])
    {
        // We are already at root level

        return self.path;
    }
    else
    {
        NSString *parentPath = [self.path.stringByDeletingLastPathComponent stringByAppendingString:@"/"];

        // Special Github URL handling
        // /Github/someuser/ -> /Github/

        if ([parentPath.stringByDeletingLastPathComponent isEqualToString:@"/Github"])
        {
            parentPath = @"/Github/";
        }

        return parentPath;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {\n\tsource = %@\n\tpath = %@\n}",
            super.description,
            self.source,
            self.path];
}

#pragma mark - NSObject Comparison Methods

- (NSUInteger)hash
{
    return self.source.hash ^ self.path.hash;
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

#pragma mark - NSCopying Methods

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) obj = [[self.class allocWithZone:zone] init];

    obj.source = self.source;
    obj.path = self.path;

    return obj;
}

@end
