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

- (NSDictionary *)dictionary
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];

    if (self.filename)
    {
        mediaInfo[@"FPPickerControllerFilename"] = self.filename;
    }

    if (self.key)
    {
        mediaInfo[@"FPPickerControllerKey"] = self.key;
    }

    if (self.originalAsset)
    {
        mediaInfo[@"FPPickerControllerOriginalAsset"] = self.originalAsset;
    }

    if (self.thumbnailImage)
    {
        mediaInfo[@"FPPickerControllerThumbnailImage"] = self.thumbnailImage;
    }

    if (self.filesize)
    {
        mediaInfo[@"FPPickerControllerFilesize"] = self.filesize;
    }

    if (self.mediaType)
    {
        mediaInfo[@"FPPickerControllerMediaType"] = self.mediaType;
    }

    if (self.mediaURL)
    {
        mediaInfo[@"FPPickerControllerMediaURL"] = self.mediaURL;
    }

    if (self.remoteURL)
    {
        mediaInfo[@"FPPickerControllerRemoteURL"] = self.remoteURL;
    }

    if (self.source)
    {
        mediaInfo[@"FPPickerControllerSource"] = self.source;
    }

    return [mediaInfo copy];
}

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
    return [NSString stringWithFormat:@"%@ (%@, containsImageAtMediaURL: %d, containsVideoAtMediaURL: %d)",
            [super description],
            self.dictionary,
            [self containsImageAtMediaURL],
            [self containsVideoAtMediaURL]];
}

@end
