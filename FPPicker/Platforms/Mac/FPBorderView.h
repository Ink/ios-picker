//
//  FPBorderView.h
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPView.h"

typedef enum : NSUInteger
{
    FPBorderTop = (1 << 0),
    FPBorderBottom = (1 << 1),
    FPBorderTopBottom = FPBorderTop | FPBorderBottom,
} FPBorderStyle;

IB_DESIGNABLE
@interface FPBorderView : FPView

@property (nonatomic, assign) IBInspectable FPBorderStyle borderStyle;
@property (nonatomic, strong) IBInspectable NSColor *borderColor;
@property (nonatomic, strong) IBInspectable NSColor *borderShadowColor;

@end
