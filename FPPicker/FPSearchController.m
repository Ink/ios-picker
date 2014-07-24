//
//  FPSearchController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPSearchController.h"
#import "FPUtils.h"

@interface FPSearchController ()

@property (nonatomic, strong) UISearchDisplayController *FPSearchDisplayController;

@end

@implementation FPSearchController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // iOS7 fix

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,
                                                                           [UIApplication sharedApplication].statusBarFrame.size.height,
                                                                           320,
                                                                           44)];

    UISearchDisplayController *searchDisplayController;

    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                contentsController:self];

    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;

    self.FPSearchDisplayController = searchDisplayController;
    self.tableView.tableHeaderView = self.FPSearchDisplayController.searchBar;
}

- (void)viewDidUnload
{
    self.tableView.tableHeaderView = nil;
    self.FPSearchDisplayController.delegate = nil;
    self.FPSearchDisplayController.searchResultsDataSource = nil;
    self.FPSearchDisplayController.searchResultsDelegate = nil;
    self.FPSearchDisplayController = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        self.contentSizeForViewInPopover = fpWindowSize;
    }

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.FPSearchDisplayController setActive:YES
                                     animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.FPSearchDisplayController.searchResultsTableView reloadData];
}

- (void)afterReload
{
    [self.FPSearchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - UISearchDisplayDelegate Methods

- (BOOL)     searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString
{
    self.path = [NSString stringWithFormat:@"%@/%@",
                 self.sourceType.rootUrl,
                 [FPUtils urlEncodeString:searchString]];

    [self fpLoadContents:self.path];
    [self.FPSearchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    // will reload when I have the results

    return NO;
}

- (BOOL)    searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // will reload when I have the results

    return NO;
}

- (void)   searchDisplayController:(UISearchDisplayController *)controller
    willHideSearchResultsTableView:(UITableView *)tableView
{
    [self.tableView reloadData];
}

@end
