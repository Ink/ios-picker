//
//  Image.h
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 24/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageBrowserItem : NSObject

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *mimetype;

@end
