//
//  AppDelegate.m
//  FPPicker iOS Demo
//
//  Created by Ruben Nine on 13/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AppDelegate.h"

@import FPPicker;

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

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Optional (makes the login screens look much nicer on iPad)

        [self iPadLoginScreenFix];
    }
}

- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private (FPPicker)

+ (void)iPadLoginScreenFix
{
    NSDictionary *userDefaults = @{
        @"UserAgent":@"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
    };

    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
}

@end
