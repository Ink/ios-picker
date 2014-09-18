//
//  FPImageBrowserView.h
//  FPPicker
//
//  Created by Ruben on 9/18/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Quartz/Quartz.h>

@class FPImageBrowserView;

@interface NSObject (FPImageBrowserDelegate)

- (BOOL)          imageBrowser:(FPImageBrowserView *)aBrowser
    shouldForwardKeyboardEvent:(NSEvent *)event;

@end


@interface FPImageBrowserView : IKImageBrowserView

@end
