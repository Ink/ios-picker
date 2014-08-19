//
//  FPPickerController.h
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPRemoteSourceController;

@interface FPPickerController : NSViewController

@property (nonatomic, weak) IBOutlet FPRemoteSourceController *remoteSourceController;
@property (nonatomic, weak) NSWindow *window;

- (IBAction)displayDropboxSource:(id)sender; // This is temporary

@end
