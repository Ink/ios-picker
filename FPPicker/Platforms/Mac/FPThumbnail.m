//
//  FPThumbnail.m
//  FPPicker
//
//  Created by Ruben Nine on 30/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPThumbnail.h"
#import <Quartz/Quartz.h>

@implementation FPThumbnail

- (NSString *)imageUID
{
    return self.UID;
}

- (NSString *)imageTitle
{
    return self.title;
}

- (NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
    return self.icon;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {icon=%@, isDimmed=%@}",
            self.title,
            self.icon,
            self.isDimmed ? @"YES"   :@"NO"];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ {icon=%@, isDimmed=%@}",
            self.title,
            self.icon,
            self.isDimmed ? @"YES"   :@"NO"];
}

@end
