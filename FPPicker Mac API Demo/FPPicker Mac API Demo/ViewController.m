//
//  ViewController.m
//  FPPicker Mac API Demo
//
//  Created by Ruben Nine on 13/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import "ViewController.h"
@import FPPickerMac;

@interface ViewController () <FPSimpleAPIDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) FPSimpleAPI *simpleAPI;
@property (nonatomic, strong) FPAuthController *authController;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end


@implementation ViewController

#pragma mark - Accessors

- (FPSimpleAPI *)simpleAPI
{
    if (!_simpleAPI)
    {
        FPSource *source = [FPSource sourceWithIdentifier:FPSourceDropbox];

        if (source)
        {
            FPSimpleAPI *api = [FPSimpleAPI simpleAPIWithSource:source];
            api.delegate = self;

            _simpleAPI = api;
        }
    }

    return _simpleAPI;
}

#pragma mark - Public Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    // Do any additional setup after loading the view.

    FPSimpleAPIMediaListCompletionBlock completionBlock = ^(NSArray *mediaList, NSUInteger nextPage, NSError *error) {
        if (error)
        {
            NSLog(@"Error getting media list: %@", error);

            NSAlert *alert = [NSAlert alertWithError:error];

            [alert runModal];
        }
        else
        {
            self.representedObject = [mediaList copy];

            NSLog(@"Got media list: %@", self.representedObject);
        }
    };

    // Get media list from Dropbox at /

    [self.simpleAPI getMediaListAtPath:@"/"
                            completion:completionBlock];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Private Methods

- (NSArray *)objects
{
    return (NSArray *)self.representedObject;
}

#pragma mark - NSTableViewDataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self objects].count;
}

#pragma mark - NSTableViewDelegate Methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [self.tableView makeViewWithIdentifier:@"DefaultCellColumn" owner:nil];
    NSDictionary *object = [self objects][row];
    NSString *title;

    if (![object[@"display_name"] isEqualToString:@""])
    {
        title = object[@"display_name"];
    }
    else
    {
        title = object[@"link_path"];
    }

    cellView.textField.stringValue = title;

    return cellView;
}

#pragma mark - FPSimpleAPIDelegate Methods

- (void)simpleAPI:(FPSimpleAPI *)simpleAPI requiresAuthenticationForSource:(FPSource *)source
{
    self.authController = [[FPAuthController alloc] initWithSource:source];

    if (self.authController)
    {
        [self.authController displayAuthSheetInModalWindow:self.view.window
                                                   success: ^{
            // NO-OP
        }
                                                   failure: ^(NSError *__nonnull error) {
            NSLog(@"Error during authentication: %@", error);

            NSAlert *alert = [NSAlert alertWithError:error];

            [alert runModal];
        }];
    }
    else
    {
        NSLog(@"FPAuthController could not be instantiated.");
    }
}

@end
