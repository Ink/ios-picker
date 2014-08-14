//
//  FPMediaInfo.m
//  FPPicker
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPMediaInfo.h"

@implementation FPMediaInfo

- (NSDictionary *)dictionary
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionaryWithCapacity:6];

    if (self.filename)
    {
        mediaInfo[@"FPPickerControllerFilename"] = self.filename;
    }

    if (self.key)
    {
        mediaInfo[@"FPPickerControllerKey"] = self.key;
    }

    if (self.originalImage)
    {
        mediaInfo[@"FPPickerControllerOriginalImage"] = self.originalImage;
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

    return [mediaInfo copy];
}

@end
