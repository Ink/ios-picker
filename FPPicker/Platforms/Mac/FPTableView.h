//
//  FPTableView.h
//  FPPicker
//
//  Created by Ruben Nine on 21/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPTableView;

@protocol FPTableViewDelegate <NSObject>

- (BOOL)             tableView:(FPTableView *)tableView
    shouldForwardKeyboardEvent:(NSEvent *)event;

@end

@interface FPTableView : NSTableView

@end
