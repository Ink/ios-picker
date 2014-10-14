//
//  FPMediaInfo.m
//  FPPicker
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPMediaInfo.h"
#import "FPUtils.h"

@implementation FPMediaInfo

- (BOOL)containsImageAtMediaURL
{
    if (self.mediaURL &&
        self.mediaType &&
        [FPUtils UTI:self.mediaType conformsToUTI:@"public.image"])
    {
        return YES;
    }

    return NO;
}

- (BOOL)containsVideoAtMediaURL
{
    if (self.mediaURL &&
        self.mediaType &&
        [FPUtils UTI:self.mediaType conformsToUTI:@"public.video"])
    {
        return YES;
    }

    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {mediaType: %@, mediaURL: %@, remoteURL: %@, filename: %@, filesize: %@, key: %@, source: %@, originalAsset: %@, thumbnailImage: %@, containsImageAtMediaURL: %@, containsVideoAtMediaURL: %@}",
            [super description],
            self.mediaType,
            self.mediaURL,
            self.remoteURL,
            self.filename,
            self.filesize,
            self.key,
            self.source,
            self.originalAsset,
            self.thumbnailImage,
            self.containsImageAtMediaURL ? @"YES":@"NO",
            self.containsVideoAtMediaURL ? @"YES":@"NO"];
}

@end
