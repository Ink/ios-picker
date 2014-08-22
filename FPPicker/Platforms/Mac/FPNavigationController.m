//
//  FPNavigationController.m
//  FPPicker
//
//  Created by Ruben Nine on 22/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPNavigationController.h"
#import "FPUtils.h"

@interface FPNavigationController ()

@property (nonatomic, weak) IBOutlet NSImageView *fpLogo;
@property (nonatomic, weak) IBOutlet NSPopUpButton *currentDirectoryPopupButton;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *navigationSegmentedControl;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *displayStyleSegmentedControl;

@end

@implementation FPNavigationController

- (void)awakeFromNib
{
    self.fpLogo.image = [[FPUtils frameworkBundle] imageForResource:@"logo_small"];

    [self populateCurrentDirectoryPopupButton];
}

#pragma mark - Private Methods

- (void)populateCurrentDirectoryPopupButton
{
    // Temporary filler code

    [self.currentDirectoryPopupButton removeAllItems];
    self.currentDirectoryPopupButton.autoenablesItems = NO;

    NSMenuItem *menuItem = [NSMenuItem new];
    NSMenuItem *menuItem2 = [NSMenuItem new];
    NSMenuItem *menuItem3 = [NSMenuItem new];

    menuItem.title = @"Item 1";
    menuItem2.title = @"Item 2";
    menuItem3.title = @"Item 3";

    [self.currentDirectoryPopupButton.menu addItem:menuItem];
    [self.currentDirectoryPopupButton.menu addItem:menuItem2];
    [self.currentDirectoryPopupButton.menu addItem:menuItem3];
    [self.currentDirectoryPopupButton.menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *recentItemsGroupItem = [NSMenuItem new];

    NSFont *font = [NSFont systemFontOfSize:11.0];

    NSDictionary *attrsDictionary = @{
        NSFontAttributeName:font,
        NSForegroundColorAttributeName:[NSColor controlShadowColor]
    };

    NSAttributedString *recentPlacesAttributedString = [[NSAttributedString alloc] initWithString:@"Recent Places"
                                                                                       attributes:attrsDictionary];

    recentItemsGroupItem.attributedTitle = recentPlacesAttributedString;
    recentItemsGroupItem.enabled = NO;

    [self.currentDirectoryPopupButton.menu addItem:recentItemsGroupItem];

    NSMenuItem *menuItem4 = [NSMenuItem new];
    NSMenuItem *menuItem5 = [NSMenuItem new];

    NSString *homePath = [@"~" stringByStandardizingPath];

    NSImage *homeFolderImage = [[NSWorkspace sharedWorkspace] iconForFile:homePath];

    homeFolderImage.size = NSMakeSize(16, 16);

    menuItem4.title = homePath.lastPathComponent;
    menuItem4.image = homeFolderImage;
    menuItem4.keyEquivalent = @"h";
    menuItem4.keyEquivalentModifierMask = NSCommandKeyMask | NSShiftKeyMask;

    NSString *documentsPath = [@"~/Documents" stringByStandardizingPath];

    NSImage *documentsFolderImage = [[NSWorkspace sharedWorkspace] iconForFile:documentsPath];

    documentsFolderImage.size = NSMakeSize(16, 16);

    menuItem5.title = documentsPath.lastPathComponent;
    menuItem5.image = documentsFolderImage;

    [self.currentDirectoryPopupButton.menu addItem:menuItem4];
    [self.currentDirectoryPopupButton.menu addItem:menuItem5];
}

@end
