//
//  FPSearchController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPSearchController.h"

@interface FPSearchController ()
@property UITableView* backgroundTableView;
@end

@implementation FPSearchController

@synthesize searchDisplayController, searchBar, backgroundTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    self.pullToRefreshEnabled = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,70,320,44)];
    //iOS7 fix
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    self.tableView.tableHeaderView = searchBar;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.searchBar = nil;
    self.searchDisplayController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.contentSizeForViewInPopover = fpWindowSize;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [searchDisplayController setActive:YES animated:YES];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //NSLog(@"Search String %@", searchString);
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.sourceType.rootUrl, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.path = path;
    [self fpLoadContents:path];
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    //will reload when I have the results
    return NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //will reload when I have the results
    return NO;
}

//On iOS7 and above because table views are transparent we get overlapping cells, so this hides the background
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        self.backgroundTableView = self.tableView;
        self.backgroundTableView.hidden = YES;
        self.tableView = tableView;
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        self.tableView = self.backgroundTableView;
        self.tableView.hidden = NO;
        self.backgroundTableView = nil;
    }
}

@end
