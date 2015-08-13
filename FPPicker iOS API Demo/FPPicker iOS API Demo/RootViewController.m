//
//  RootViewController.m
//  FPPicker iOS API Demo
//
//  Created by Ruben Nine on 13/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import "RootViewController.h"
@import FPPicker;

@interface RootViewController () <FPSimpleAPIDelegate, UITableViewDataSource>

@property (nonatomic, strong) FPSimpleAPI *simpleAPI;
@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation RootViewController

#pragma mark - Accessors

- (NSMutableArray *)objects
{
    if (!_objects)
    {
        _objects = [NSMutableArray array];
    }

    return _objects;
}

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

    FPSimpleAPIMediaListCompletionBlock completionBlock = ^(NSArray *mediaList, NSUInteger nextPage, NSError *error) {
        if (error)
        {
            NSLog(@"Error getting media list: %@", error);

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting media list"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            self.objects = [mediaList copy];

            NSLog(@"Got media list: %@", self.objects);

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    };

    // Get media list from Dropbox at /

    [self.simpleAPI getMediaListAtPath:@"/"
                            completion:completionBlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *object = self.objects[indexPath.row];

    cell.textLabel.text = object[@"display_name"];
    cell.detailTextLabel.text = object[@"link_path"];

    return cell;
}

#pragma mark - FPSimpleAPIDelegate Methods

- (void)simpleAPI:(FPSimpleAPI *)simpleAPI requiresAuthenticationForSource:(FPSource *)source
{
    FPAuthController *authController = [[FPAuthController alloc] initWithSource:source];

    if (authController)
    {
        [self.navigationController pushViewController:authController animated:YES];
    }
    else
    {
        NSLog(@"FPAuthController could not be instantiated.");
    }
}

@end
