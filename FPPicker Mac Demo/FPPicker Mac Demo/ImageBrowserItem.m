//
//  Image.m
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 24/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "ImageBrowserItem.h"

@implementation ImageBrowserItem

#pragma mark - IKImageBrowserItem Data Source Protocol Methods

- (NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
    return self.image;
}

- (NSString *)imageUID
{
    return [NSString stringWithFormat:@"%ld", (long)self.image.hash];
}

- (NSString *)imageTitle
{
    return self.title;
}

@end
