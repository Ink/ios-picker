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

@property (nonatomic, strong) UITableView *backgroundTableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@end

@implementation FPSearchController

@synthesize searchDisplayController = _ourSearchDisplayController;

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

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

    // iOS7 fix

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }

    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                                     contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;

    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        [self.view addSubview:self.searchBar];
    }
    else
    {
        self.tableView.tableHeaderView = self.searchBar;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.searchBar = nil;
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    self.searchDisplayController = nil;
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
    [self.searchDisplayController setActive:YES
                                   animated:YES];
}

- (BOOL)     searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString
{
    //NSLog(@"Search String %@", searchString);
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      self.sourceType.rootUrl,
                      [FPUtils urlEncodeString:searchString]];

    self.path = path;

    [self fpLoadContents:path];
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    // will reload when I have the results

    return NO;
}

- (BOOL)    searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // will reload when I have the results

    return NO;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)   searchDisplayController:(UISearchDisplayController *)controller
    willShowSearchResultsTableView:(UITableView *)tableView
{
    self.backgroundTableView = self.tableView;
    self.backgroundTableView.hidden = YES;
    self.tableView = tableView;
}

- (void)   searchDisplayController:(UISearchDisplayController *)controller
    willHideSearchResultsTableView:(UITableView *)tableView
{
    self.tableView = self.backgroundTableView;
    self.tableView.hidden = NO;
    self.backgroundTableView = nil;
}

@end
