//
//  AppDelegate.m
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "AppDelegate.h"

@import FPPickerMac;

@implementation AppDelegate

+ (void)initialize
{
    //! Filepicker.io configuration (required)

    [FPConfig sharedInstance].APIKey = @"SET_FILEPICKER.IO_APIKEY_HERE";

    //! Filepicker.io configuration (optional)

    //! [FPConfig sharedInstance].appSecretKey = @"SET_FILEPICKER.IO_APPSECRETKEY_HERE";
    //! [FPConfig sharedInstance].storeAccess = @"private";
    //! [FPConfig sharedInstance].storeContainer = @"some-alt-container";
    //! [FPConfig sharedInstance].storeLocation = @"S3";
    //! [FPConfig sharedInstance].storePath = @"some-path-within-bucket/";
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

@end
