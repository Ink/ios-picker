//
//  FPNavigationController.m
//  FPPicker
//
//  Created by Ruben Nine on 22/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPNavigationController.h"
#import "FPInternalHeaders.h"
#import "FPUtils.h"

@interface FPNavigationController ()

@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, weak) IBOutlet NSImageView *fpLogo;
@property (nonatomic, weak) IBOutlet NSPopUpButton *currentDirectoryPopupButton;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *navigationSegmentedControl;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *displayStyleSegmentedControl;

@end

@implementation FPNavigationController

- (void)awakeFromNib
{
    self.fpLogo.image = [[FPUtils frameworkBundle] imageForResource:@"logo_small"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sourcePathDidChange:)
                                                 name:FPSourcePathDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sourcePathDidChange:(NSNotification *)sender
{
    self.currentPath = sender.object;

    [self populateCurrentDirectoryPopupButton];
}

#pragma mark - Private Methods

- (void)populateCurrentDirectoryPopupButton
{
    [self.currentDirectoryPopupButton removeAllItems];
    self.currentDirectoryPopupButton.autoenablesItems = NO;

    NSArray *pathComponents = [self currentPathComponents];

    [pathComponents.reverseObjectEnumerator.allObjects enumerateObjectsUsingBlock: ^(id obj,
                                                                                     NSUInteger idx,
                                                                                     BOOL *stop) {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];

        icon.size = NSMakeSize(16, 16);

        NSMenuItem *menuItem = [NSMenuItem new];

        menuItem.title = [obj stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        menuItem.image = icon;
        menuItem.representedObject = [self fullPathToRelativePath:obj];
        menuItem.target = self;
        menuItem.action = @selector(currentDirectoryPopupButtonSelectionChanged:);

        [self.currentDirectoryPopupButton.menu addItem:menuItem];
    }];

    if (pathComponents.count > 0)
    {
        [self.currentDirectoryPopupButton selectItemAtIndex:0];
    }
}

- (IBAction)currentDirectoryPopupButtonSelectionChanged:(id)sender
{
    NSString *newPath = [sender representedObject];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(currentDirectoryPopupButtonSelectionChanged:)])
    {
        [self.delegate currentDirectoryPopupButtonSelectionChanged:newPath];
    }
}

#pragma mark - Private Methods

- (NSArray *)currentPathComponents
{
    NSMutableArray *pathComponents = [[self.currentPath componentsSeparatedByString:@"/"] mutableCopy];

    [pathComponents removeObject:@""];

    return [pathComponents copy];
}

- (NSString *)fullPathToRelativePath:(NSString *)relativePath
{
    NSArray *currentPathComponents = [self currentPathComponents];
    NSString *representedPath = [NSString stringWithFormat:@"/%@/", currentPathComponents[0]];

    if (currentPathComponents.count > 1)
    {
        for (NSUInteger i = 1; i <= [currentPathComponents indexOfObject:relativePath]; i++)
        {
            NSString *extra = [NSString stringWithFormat:@"%@/", currentPathComponents[i]];

            representedPath = [representedPath stringByAppendingString:extra];
        }
    }

    return representedPath;
}

@end
