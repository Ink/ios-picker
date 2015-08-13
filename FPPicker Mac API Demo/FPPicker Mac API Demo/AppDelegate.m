//
//  AppDelegate.m
//  FPPicker Mac API Demo
//
//  Created by Ruben Nine on 13/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import "AppDelegate.h"
@import FPPickerMac;

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    [super initialize];

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

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

@end
