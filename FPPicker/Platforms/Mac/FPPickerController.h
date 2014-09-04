//
//  FPPickerController.h
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FPPickerController : NSWindowController

@property (nonatomic, weak) IBOutlet NSTextField *currentSelectionTextField;

- (void)open;

@end
