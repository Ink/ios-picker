//
//  FPPickerController.m
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPPickerController.h"
#import "FPPrivateConfig.h"
#import "FPRemoteSourceController.h"
#import "FPSource.h"

@interface FPPickerController ()

@end

@implementation FPPickerController

- (NSWindow *)window
{
    if (!_window)
    {
        _window = self.view.window;
    }

    return _window;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];

        self = [[self.class alloc] initWithNibName:@"FPPickerController"
                                            bundle:frameworkBundle];
    }

    return self;
}

- (IBAction)displayDropboxSource:(id)sender
{
    // This is temporary

    [self.window makeKeyAndOrderFront:self];

    FPSource *source = [FPSource new];

    source.identifier = @"dropbox";
    source.name = @"Dropbox";
    source.icon = @"glyphicons_361_dropbox";
    source.rootUrl = @"/Dropbox";
    source.open_mimetypes = @[@"*/*"];
    source.save_mimetypes = @[@"*/*"];
    source.overwritePossible = YES;
    source.externalDomains = @[@"https://www.dropbox.com"];

    self.remoteSourceController.source = source;

    [self.remoteSourceController fpLoadContentAtPath];
}

@end
