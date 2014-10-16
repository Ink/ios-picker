//
//  FPSaveController.m
//  FPPicker
//
//  Created by Ruben Nine on 15/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSaveController.h"
#import "FPInternalHeaders.h"
#import "FPSourceListController.h"
#import "FPSourceViewController.h"
#import "FPFileUploadController.h"

@interface FPSaveController  () <NSSplitViewDelegate,
                                 NSWindowDelegate,
                                 FPFileTransferControllerDelegate>

@property (nonatomic, weak) IBOutlet NSImageView *fpLogo;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *displayStyleSegmentedControl;
@property (nonatomic, weak) IBOutlet FPSourceViewController *sourceViewController;
@property (nonatomic, weak) IBOutlet FPSourceListController *sourceListController;

@property (nonatomic, assign) NSModalSession modalSession;
@property (nonatomic, strong) FPFileUploadController *uploadController;

@end

@implementation FPSaveController

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.fpLogo.image = [[FPUtils frameworkBundle] imageForResource:@"logo_small"];
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [[self.class alloc] initWithWindowNibName:@"FPSaveController"];
    }

    return self;
}

- (void)open
{
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];

    [NSApp runModalSession:self.modalSession];
}

#pragma mark - Actions

- (IBAction)saveFile:(id)sender
{
    NSString *filename = self.sourceViewController.filenameTextField.stringValue;
    NSString *path = self.sourceViewController.currentPath;

    if (self.data)
    {
        self.uploadController = [[FPFileUploadController alloc] initWithData:self.data
                                                                    filename:filename
                                                                  targetPath:path
                                                                 andMimetype:self.dataType];
    }
    else if (self.dataURL)
    {
        self.uploadController = [[FPFileUploadController alloc] initWithDataURL:self.dataURL
                                                                       filename:filename
                                                                     targetPath:path
                                                                    andMimetype:self.dataType];
    }

    if (!self.uploadController)
    {
        DLog(@"No upload controller was intanstiated.");

        return;
    }

    self.uploadController.delegate = self;

    [self.uploadController process];


    {
        [self.window close];
    }
}

- (IBAction)close:(id)sender
{
    [self.sourceViewController cancelAllOperations];
    [self.window close];
}

#pragma mark - FPFileTransferControllerDelegate Methods

- (void)FPFileTransferControllerDidFinish:(FPFileTransferController *)transferController
                                     info:(id)info
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPSaveController:didFinishSavingMediaWithInfo:)])
    {
        [self.delegate FPSaveController:self
           didFinishSavingMediaWithInfo:info];
    }
    else
    {
        DLog(@"Upload finished: %@", info);
    }
}

- (void)FPFileTransferControllerDidFail:(FPFileTransferController *)transferController
                                  error:(NSError *)error
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPSaveController:didError:)])
    {
        [self.delegate FPSaveController:self
                               didError:error];
    }
    else
    {
        DLog(@"Upload failed: %@", error);
    }
}

- (void)FPFileTransferControllerDidCancel:(FPFileTransferController *)transferController
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(FPSaveControllerDidCancel:)])
    {
        [self.delegate FPSaveControllerDidCancel:self];
    }
    else
    {
        DLog(@"Upload was cancelled");
    }
}

#pragma mark - NSWindowDelegate Methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.sourceViewController.allowsFileSelection = NO;
    self.sourceViewController.allowsMultipleSelection = NO;
    self.sourceViewController.filenameTextField.stringValue = self.proposedFilename;

    self.sourceListController.sourceNames = self.sourceNames;
    self.sourceListController.dataTypes = @[self.dataType];

    [self.sourceListController loadAndExpandSourceListIfRequired];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (self.modalSession)
    {
        [NSApp endModalSession:self.modalSession];
    }
}

#pragma mark - NSSplitViewDelegate Methods

- (BOOL)           splitView:(NSSplitView *)splitView
    shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return YES;
}

- (BOOL)     splitView:(NSSplitView *)splitView
    canCollapseSubview:(NSView *)subview
{
    return NO;
}

- (CGFloat)      splitView:(NSSplitView *)splitView
    constrainMinCoordinate:(CGFloat)proposedMinimumPosition
               ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < 150)
    {
        proposedMinimumPosition = 150;
    }

    return proposedMinimumPosition;
}

- (CGFloat)      splitView:(NSSplitView *)splitView
    constrainMaxCoordinate:(CGFloat)proposedMinimumPosition
               ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition > 225)
    {
        proposedMinimumPosition = 225;
    }

    return proposedMinimumPosition;
}

@end
