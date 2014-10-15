//
//  FPThumbnail.h
//  FPPicker
//
//  Created by Ruben Nine on 30/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPThumbnail : NSObject

@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *UID;
@property (nonatomic, assign) BOOL isDimmed;

@end
