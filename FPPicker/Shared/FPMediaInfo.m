//
//  FPMediaInfo.m
//  FPPicker
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPMediaInfo.h"
#import "FPUtils.h"
#import "FPSource.h"

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
    return [NSString stringWithFormat:@"%@ {\n\tmediaType = %@\n\tmediaURL = %@\n\tremoteURL = %@\n\tfilename = %@\n\tfilesize = %@\n\tkey = %@\n\tsource = %@\n\toriginalAsset = %@\n\tthumbnailImage = %@\n\tcontainsImageAtMediaURL = %@\n\tcontainsVideoAtMediaURL = %@\n}",
            super.description,
            self.mediaType,
            self.mediaURL,
            self.remoteURL,
            self.filename,
            self.filesize,
            self.key,
            self.source.identifier,
            self.originalAsset,
            self.thumbnailImage,
            self.containsImageAtMediaURL ? @"YES":@"NO",
            self.containsVideoAtMediaURL ? @"YES":@"NO"];
}

@end
