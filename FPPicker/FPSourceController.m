//
//  ServiceController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPSourceController.h"
#import "FPSaveController.h"
#import "FPAuthController.h"
#import "FPInternalHeaders.h"
#import "FPThumbCell.h"
#import "FPProgressTracker.h"

@interface FPSourceController ()

@property int padding;
@property int numPerRow;
@property int thumbSize;
@property NSMutableSet *selectedObjects;
//Map from object id to thumbnail
@property NSMutableDictionary *selectedObjectThumbnails;

@end

@implementation FPSourceController

@synthesize contents, path, sourceType, viewType, nextPage, nextPageSpinner, fpdelegate, precacheOperations;
@synthesize padding, numPerRow, thumbSize;
@synthesize selectedObjects = _selectedObjects;
@synthesize selectedObjectThumbnails = _selectedObjectThumbnails;

UIImage *selectOverlay;
UIImage *selectIcon;
NSInteger ROW_HEIGHT = 44;
static const CGFloat UPLOAD_BUTTON_CONTAINER_HEIGHT = 45.f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedObjects = [NSMutableSet setWithCapacity:self.maxFiles == 0 ? 10 : self.maxFiles];
        self.selectedObjectThumbnails = [NSMutableDictionary dictionaryWithCapacity:self.maxFiles == 0 ? 10 : self.maxFiles];
    }
    return self;
}

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Make sure that we have a service
    if (self.sourceType == nil){ return; }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        selectOverlay = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"SelectOverlayiOS7" ofType:@"png"]];
    } else {
        selectOverlay = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"SelectOverlay" ofType:@"png"]];
    }
    selectIcon = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"glyphicons_206_ok_2" ofType:@"png"]];

    if (path == nil){ path = [NSString stringWithFormat:@"%@/", self.sourceType.rootUrl]; }

    if (![self.sourceType.identifier isEqualToString:FPSourceImagesearch]){
        //For Image Search, loading root is useless
        [self fpLoadContents:path];
    }

    [self setTitle:sourceType.name];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.precacheOperations = [[NSMutableDictionary alloc] init];
    
    if (self.selectMultiple && ![viewType isEqualToString:@"thumbnails"]){
        self.tableView.allowsSelection = YES;
        self.tableView.allowsMultipleSelection = YES;
    };
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.contents = nil;
    self.path = nil;
    self.sourceType = nil;
    self.fpdelegate = nil;
    //TODO: get rid of precaching ops
    self.precacheOperations = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.contentSizeForViewInPopover = fpWindowSize;
    
    CGRect bounds = [self getViewBounds];
    self.thumbSize = fpRemoteThumbSize;
    self.numPerRow = (int) bounds.size.width/self.thumbSize;
    self.padding = (int)((bounds.size.width - numPerRow*self.thumbSize)/ ((float)numPerRow + 1));
    if (padding < 4){
        self.numPerRow -= 1;
        self.padding = (int)((bounds.size.width - numPerRow*self.thumbSize)/ ((float)numPerRow + 1));
    }

    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //remove the pull down login label if applicable.
    UIView *v = [self.view viewWithTag:[@"-1" integerValue]];
    if (v != nil){
        [v removeFromSuperview];
    }
    v = [self.view viewWithTag:[@"-2" integerValue]];
    if (v != nil) {
        [v removeFromSuperview];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)passedTableView
{
    if (self.nextPage != nil){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)passedTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        if ([viewType isEqualToString:@"thumbnails"]){
            NSLog(@"Numofrows: %d %lu", (int) ceil([self.contents count]/(self.numPerRow*1.0)), (unsigned long)[self.contents count]);
            return (int) ceil([self.contents count]/(self.numPerRow*1.0));
        } else {
            return [self.contents count];
        }
    } else if (section == 1){
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)passedTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([viewType isEqualToString:@"thumbnails"]){
        return self.thumbSize+self.padding;
    }
    return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)passedTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){ //If it is the load more section
        [self fpLoadNextPage]; //Load More Stuff from Internet
    }
}

- (UITableViewCell *)tableView:(UITableView *)passedTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = fpCellIdentifier;
    FPThumbCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[FPThumbCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } else {
        // You need to cancel the old precache request.
        if ([precacheOperations objectForKey:[NSString stringWithFormat:@"precache_%ld", (long)indexPath.row]]){
            [(FPAFURLConnectionOperation*)[precacheOperations objectForKey:[NSString stringWithFormat:@"precache_%ld", (long)indexPath.row]] cancel];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.imageView.alpha = 1.0;
        cell.imageView.image = nil;
        cell.textLabel.text = @"";
        cell.userInteractionEnabled = YES;
        for (UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
    }

    if (self.nextPage != nil && indexPath.section == 1){
        return [self setupLoadMoreCell:cell];
    }
    
    if ([viewType isEqualToString:@"thumbnails"]){
        return [self setupThumbnailCell:cell atIndex:indexPath.row];
    } else {
        return [self setupListCell:cell atIndex:indexPath.row];
    }
}

- (UITableViewCell*)setupLoadMoreCell:(UITableViewCell*)cell {
    nextPageSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    nextPageSpinner.hidesWhenStopped = YES;
    
    NSInteger height = ROW_HEIGHT;
    if ([viewType isEqualToString:@"thumbnails"]){
        height = self.thumbSize+self.padding;
    }
    nextPageSpinner.frame = CGRectMake(floorf(floorf(height - 20) / 2), floorf((height - 20) / 2), 20, 20);
    
    [cell addSubview:nextPageSpinner];
    [nextPageSpinner startAnimating];
    
    
    cell.textLabel.text = @"Loading more";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.userInteractionEnabled = NO;
    
    return cell;
}

- (UITableViewCell*)setupThumbnailCell:(UITableViewCell*)cell atIndex:(NSInteger)itemIndex {
    NSLog(@"Thumbnail");
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTappedWithGesture:)];
    [cell.contentView addGestureRecognizer:tap];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGRect rect = CGRectMake(self.padding, self.padding, self.thumbSize, self.thumbSize);
    for (int i=0; i<self.numPerRow; i++) {
        NSInteger index = self.numPerRow*itemIndex + i;
        NSLog(@"index: %ld", (long)index);
        if (index >= [self.contents count]){
            break;
        }
        
        if (index >= [self.contents count]){ return cell; }
        NSMutableDictionary *obj = [self.contents objectAtIndex:index];
        NSString *urlString = [obj valueForKey:@"thumbnail"];
        
        NSMutableURLRequest *mrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        if (![urlString hasPrefix:fpBASE_URL]){
            NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:fpBASE_URL]]];
            [mrequest setAllHTTPHeaderFields:headers];
        }
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
        image.tag = index;
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        if ([[NSNumber numberWithInt:1] isEqual:[obj valueForKey:@"disabled"]]){
            image.alpha = 0.5;
        } else {
            image.alpha = 1.0;
        }
        
        
        //NSLog(@"Request: %@", mrequest);
        [image FPsetImageWithURLRequest:mrequest placeholderImage:[UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"placeholder" ofType:@"png"]] success:nil failure:nil];
        
        BOOL thumbExists = [[NSNumber numberWithInt:1] isEqualToNumber:[obj valueForKey:@"thumb_exists"]];
        
        if (!thumbExists){
            UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.thumbSize-30, self.thumbSize, 30)];
            [subLabel setTextColor:[UIColor blackColor]];
            [subLabel setFont:[UIFont systemFontOfSize:16]];
            [subLabel setBackgroundColor:[UIColor clearColor]];
            [subLabel setText: [obj valueForKey:@"filename"]];
            [subLabel setTextAlignment:NSTextAlignmentCenter];
            [image addSubview:subLabel];
            image.contentMode = UIViewContentModeCenter;
            image.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
            
        } else {
            image.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        
        if (self.selectMultiple) {
            //Add overlay
            UIImageView *overlay = [[UIImageView alloc] initWithImage:selectOverlay];
            overlay.frame = image.bounds;
            
            //If this object is selected, leave the overlay on.
            overlay.hidden = ![self.selectedObjects containsObject:obj];
            
            overlay.opaque = NO;
            [image addSubview:overlay];
        }
        
        [cell.contentView addSubview:image];
        rect = CGRectMake((rect.origin.x+self.thumbSize+self.padding), rect.origin.y, rect.size.width, rect.size.height);
    }
    return cell;
}

- (UITableViewCell*)setupListCell:(UITableViewCell*)cell atIndex:(NSInteger)itemIndex {
    if (itemIndex >= [self.contents count]){ return cell; }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;;
    
    NSMutableDictionary *obj = [self.contents objectAtIndex:itemIndex];

    cell.tag = itemIndex;
    cell.textLabel.text = [obj valueForKey:@"filename"];
    
    if ([[NSNumber numberWithInt:1] isEqualToNumber:[obj valueForKey:@"is_dir"]]){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor blackColor];
        [self fpPreloadContents:[obj valueForKey:@"link_path"] forCell:cell.tag];
    }
    NSLog(@"Thumb exists%@", [obj valueForKey:@"thumb_exists"]);
    
    BOOL thumbExists = (BOOL)[obj valueForKey:@"thumb_exists"];
    BOOL isDir = [[NSNumber numberWithInt:1] isEqualToNumber:[obj valueForKey:@"is_dir"]];
    
    if (thumbExists){
        NSString *urlString = [obj valueForKey:@"thumbnail"];
        
        NSLog(@"Thumb with URL: %@", urlString);
        
        NSMutableURLRequest *mrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        if (![urlString hasPrefix:fpBASE_URL]){
            NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:fpBASE_URL]]];
            [mrequest setAllHTTPHeaderFields:headers];
            NSLog(@"headers %@", headers);
        }
        
        if (isDir){
            cell.imageView.image = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"glyphicons_144_folder_open" ofType:@"png"]];
            cell.imageView.contentMode = UIViewContentModeCenter;
            
        } else {
            [cell.imageView FPsetImageWithURLRequest:mrequest placeholderImage:[UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"placeholder" ofType:@"png"]] success:nil failure:nil];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
    } else {
        if (isDir){
            cell.imageView.image = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"glyphicons_144_folder_open" ofType:@"png"]];
        } else {
            cell.imageView.image = [UIImage imageWithContentsOfFile:[[FPLibrary frameworkBundle] pathForResource:@"glyphicons_036_file" ofType:@"png"]];
        }
        cell.imageView.contentMode = UIViewContentModeCenter;
    }
    
    if ([[NSNumber numberWithInt:1] isEqual:[obj valueForKey:@"disabled"]]){
        cell.textLabel.textColor = [UIColor grayColor];
        cell.imageView.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    }
    if (isDir) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)passedTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)passedTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)passedTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *thumbnail = [self.tableView cellForRowAtIndexPath:indexPath].imageView.image;
    NSMutableDictionary *obj = [self.contents objectAtIndex:indexPath.row];

    BOOL thumbExists = (BOOL) [obj valueForKey:@"thumb_exists"];
    if (thumbExists){
        [self objectSelectedAtIndex:indexPath.row withThumbnail:thumbnail];
    } else {
        [self objectSelectedAtIndex:indexPath.row];
    }
}


- (void)tableView:(UITableView *)passedTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *obj = [self.contents objectAtIndex:indexPath.row];
    
    if ([self.selectedObjects containsObject:obj]) {
        [self.selectedObjects removeObject:obj];
    } else {
        [self.selectedObjects addObject:obj];
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [self updateUploadButton:self.selectedObjects.count];
    });
}


- (void) fpAuthResponse {
    [self fpLoadContents:path cachePolicy:NSURLRequestReloadIgnoringCacheData];
}

/*  
 *  The default wrapper for fpLoadContents.
 *  I presume that cached data is fine unless you specify specifically.
 */
- (void) fpLoadContents:(NSString *)loadpath {
    [self fpLoadContents:loadpath cachePolicy:NSURLRequestReturnCacheDataElseLoad];
}


- (void) fpLoadContents:(NSString *)loadpath cachePolicy:(NSURLRequestCachePolicy) policy {
    
    FPMBProgressHUD *hud = [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading contents";

    NSURLRequest *request = [self requestForLoadPath:loadpath withFormat:@"info" cachePolicy:policy];
    
    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest: request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self fpLoadResponseSuccessAtPath:loadpath withResult:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self fpLoadResponseFailureAtPath:loadpath withError:error];
    }];
    
    if ([sourceType.identifier isEqualToString:FPSourceImagesearch]){
        FPAFJSONRequestOperation *oldOperation = (FPAFJSONRequestOperation *) [precacheOperations objectForKey:@"imagesearch_"];
        [oldOperation cancel];
        [precacheOperations removeObjectForKey:@"imagesearch_"];
        [precacheOperations setObject:operation forKey:@"imagesearch_"];
        
    }
    
    [operation start];
    
}

- (void) fpLoadResponseSuccessAtPath:(NSString*)loadpath withResult:(id)JSON {
    NSLog(@"Loading Contents: %@", JSON);
    
    self.contents = [ JSON valueForKeyPath:@"contents"];
    self.viewType = [ JSON valueForKeyPath:@"view"];
    
    NSString *next = [ JSON valueForKeyPath:@"next"];
    if (next && next != (NSString*)[NSNull null]){
        self.nextPage = next ;
    } else {
        self.nextPage = nil;
    }
    
    if (![viewType isEqualToString:@"thumbnails"]){
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    [self setTitle:[JSON valueForKey:@"filename"]];
    
    if ([JSON valueForKey:@"auth"] ){
        [self launchAuthView];
    } else {
        if ([loadpath isEqualToString:[NSString stringWithFormat:@"%@/", self.sourceType.rootUrl]]){
            //logout only on root level
            UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
            self.navigationItem.rightBarButtonItem = anotherButton;
        }
        
        if ([[JSON valueForKeyPath:@"contents"] count] == 0 && (sourceType.identifier != FPSourceImagesearch)){
            NSLog(@"nothing");
            [self setupEmptyView];
        }
    }
    
    [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self stopLoading];
    [self.tableView reloadData];
    NSLog(@"after reload");
    if ([sourceType.identifier isEqualToString:FPSourceImagesearch]){
        //NSLog(@"%@", self.searchDisplayController);
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    [self afterReload];
}

- (void) launchAuthView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fpAuthResponse) name:@"auth" object:nil];
    
    FPAuthController *authView = [[FPAuthController alloc] init];
    authView.service = sourceType.identifier;
    authView.title = sourceType.name;
    [self.navigationController pushViewController:authView animated:NO];
}

- (void) setupEmptyView {
    CGRect bounds = [self getViewBounds];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (bounds.size.height)/2-60, bounds.size.width, 30)];
    headingLabel.tag = -1;
    [headingLabel setTextColor:[UIColor grayColor]];
    [headingLabel setFont:[UIFont systemFontOfSize:25]];
    [headingLabel setTextAlignment:NSTextAlignmentCenter];
    headingLabel.text = @"No files here";
    [self.view addSubview:headingLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (bounds.size.height)/2-30, bounds.size.width, 30)];
    subLabel.tag = -2;
    [subLabel setTextColor:[UIColor grayColor]];
    [subLabel setTextAlignment:NSTextAlignmentCenter];
    subLabel.text = @"Pull down to refresh";
    [self.view addSubview:subLabel];
}

- (void) fpLoadResponseFailureAtPath:(NSString*)loadpath withError:(NSError*)error {
    [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSLog(@"Error: %@", error);
    
    //NSLog(@"Loading Contents: %@", JSON);
    
    
    if (error.code == -1009 || error.code == -1001){
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                          message:@"You aren't connected to the internet so we can't get your files."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
    
    if (error.code == -1011){
        [self fpLoadContents:loadpath cachePolicy:NSURLRequestReloadIgnoringCacheData];
    }
    [self stopLoading];
}

- (void) fpPreloadContents:(NSString *)loadpath {
    [self fpPreloadContents:loadpath forCell:-1];
}

- (void) fpPreloadContents:(NSString *)loadpath cachePolicy:(NSURLRequestCachePolicy)policy {
    NSLog(@"trying to refresh a path");
    [self fpPreloadContents:loadpath forCell:-1 cachePolicy:policy ];
}

- (void) fpPreloadContents:(NSString *)loadpath forCell:(NSInteger)cellIndex {
    [self fpPreloadContents:loadpath forCell:cellIndex cachePolicy:NSURLRequestReturnCacheDataElseLoad ];
}


- (void) fpPreloadContents:(NSString *)loadpath forCell:(NSInteger)cellIndex cachePolicy:(NSURLRequestCachePolicy)policy {
    NSInteger nilInteger = -1;
    
    NSURLRequest *request = [self requestForLoadPath:loadpath withFormat:@"info" cachePolicy:policy];
    
    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest: request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"JSON: %@", JSON);
        if (cellIndex != nilInteger){
            [precacheOperations removeObjectForKey:[NSString stringWithFormat:@"precache_%ld", (long)cellIndex]];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (cellIndex != nilInteger){
            [precacheOperations removeObjectForKey:[NSString stringWithFormat:@"precache_%ld", (long)cellIndex]];
        }
    }];
    [operation start];
    
    if (cellIndex != nilInteger){
        [precacheOperations setObject:operation forKey:[NSString stringWithFormat:@"precache_%ld", (long)cellIndex]];
    }
    
}


- (void) fpLoadNextPage {
    // Encode a string to embed in an URL.
    NSLog(@"Next page: %@", self.nextPage);
    NSString *encoded = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                (__bridge CFStringRef) self.nextPage,
                                                NULL,
                                                (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                kCFStringEncodingUTF8);

    NSString *nextPageParam = [NSString stringWithFormat:@"&start=%@", encoded];
    NSLog(@"nextpageparm: %@", nextPageParam);
    NSURLRequest *request = [self requestForLoadPath:self.path withFormat:@"info" byAppending:nextPageParam cachePolicy:NSURLRequestReloadIgnoringCacheData];
    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest: request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", JSON);
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.contents];
        [tempArray addObjectsFromArray:[ JSON valueForKeyPath:@"contents"]];
        self.contents = tempArray;
        
        NSString *next = [ JSON valueForKeyPath:@"next"];
        if (next && next != (NSString*)[NSNull null]){
            self.nextPage = next ;
        } else {
            self.nextPage = nil;
        }
        [self.tableView reloadData];
        [nextPageSpinner stopAnimating];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"JSON: %@", JSON);
        self.nextPage = nil;
        [self.tableView reloadData];
        [nextPageSpinner stopAnimating];
        
    }];
    [operation start];
    
}

- (IBAction)singleTappedWithGesture:(UIGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationOfTouch:sender.view.tag inView:sender.view];
   
    int rowIndex = (int) fmin(floor(tapPoint.x/105), self.numPerRow - 1);
    
    //Do nothing if there isn't a corresponding image view.
    if (rowIndex >= [sender.view.subviews count]){
        return;
    }
    
    UIImageView *selectedView = [sender.view.subviews objectAtIndex:rowIndex];
    
    NSMutableDictionary *obj = [self.contents objectAtIndex:selectedView.tag];
    UIImage *thumbnail;
    BOOL thumbExists = [[NSNumber numberWithInt:1] isEqualToNumber:[obj valueForKey:@"thumb_exists"]];
    if (thumbExists){
        thumbnail = selectedView.image;
        [self objectSelectedAtIndex:selectedView.tag withThumbnail:thumbnail];
    } else {
        [self objectSelectedAtIndex:selectedView.tag];        
    }
}

- (void) objectSelectedAtIndex:(NSInteger) index {
    [self objectSelectedAtIndex:index withThumbnail:nil];
}

- (void) objectSelectedAtIndex:(NSInteger) index withThumbnail:(UIImage *) thumbnail {
    NSDictionary *obj = [self.contents objectAtIndex:index];
    
    if ([[NSNumber numberWithInt:1] isEqual:[obj valueForKey:@"disabled"]]){
        return;
    } else if ([[NSNumber numberWithInt:1] isEqualToNumber:[obj valueForKey:@"is_dir"]]){
        FPSourceController *subController = [[FPSourceController alloc] init];
        subController.path = [obj valueForKey:@"link_path"];
        subController.sourceType = sourceType;
        subController.fpdelegate = fpdelegate;
        subController.selectMultiple = self.selectMultiple;
        subController.maxFiles = self.maxFiles;
        [self.navigationController pushViewController:subController animated:YES];
        return;
    }

    
    if (self.selectMultiple) {
        UIView *view = [self.view viewWithTag:index];
        if ([viewType isEqualToString:@"thumbnails"]){
            [self toggleSelectionOnThumbnailView:view];
        }
        //Table selection takes care of list views, so no need for an else
        
        if ([self.selectedObjects containsObject:obj]) {
            [self.selectedObjects removeObject:obj];
            [self.selectedObjectThumbnails removeObjectForKey:[NSNumber numberWithInteger:index]];
        } else {
            [self.selectedObjects addObject:obj];
            if (thumbnail) {
                [self.selectedObjectThumbnails setObject:thumbnail forKey:[NSNumber numberWithInteger:index]];
            }
        }
        dispatch_async(dispatch_get_main_queue(),^{
            [self updateUploadButton:self.selectedObjects.count];
        });
    } else {
        FPMBProgressHUD __block *hud;
        dispatch_async(dispatch_get_main_queue(),^{
            hud = [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = FPMBProgressHUDModeDeterminate;
            hud.labelText = @"Downloading file";
        });
        [self fetchObject:obj withThumbnail:thumbnail success:^(NSDictionary *data) {
            dispatch_async(dispatch_get_main_queue(),^{
                [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [fpdelegate FPSourceController:self didFinishPickingMediaWithInfo:data];
            });
        } failure:^(NSError *error) {
            NSLog(@"FAIL %@", error);
            if (error.code == -1009 || error.code == -1001){
                [self.navigationController popViewControllerAnimated:YES];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                                  message:@"You aren't connected to the internet so we can't get your files."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                
                [message show];
            }
            
            dispatch_async(dispatch_get_main_queue(),^{
                [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [fpdelegate FPSourceControllerDidCancel:self];
            });
        } progress:^(float progress) {
            hud.progress = progress;
        }];
    }
}

- (void) toggleSelectionOnThumbnailView:(UIView*)view {
    //View is an image view
    UIImageView* imageView = (UIImageView*)view;
    dispatch_async(dispatch_get_main_queue(),^{
        UIView* overlay = [imageView.subviews objectAtIndex:0];
        overlay.hidden = !overlay.hidden;
    });
}

- (void) uploadButtonTapped:(id)sender {
    [super uploadButtonTapped:sender];
    
    FPMBProgressHUD *hud = [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = FPMBProgressHUDModeDeterminate;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:self.selectedObjects.count];
    
    //TODO: What should we do on failures? Right now we just press forward, but
    //You could imagine wanting to fail fast
    NSInteger __block totalCount = self.selectedObjects.count;
    if (totalCount == 1) {
        hud.labelText = @"Downloading 1 file";
    } else {
        hud.labelText = [NSString stringWithFormat:@"Downloading 1 of %ld files", (long)totalCount];
    }
    
    FPProgressTracker* progressTracker = [[FPProgressTracker alloc] initWithObjectCount:self.selectedObjects.count];
    
    for (NSDictionary* obj in self.selectedObjects) {
        //We push all the uploads onto background threads. Now we have to be careful
        //as we're working in multi-threaded environment.
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            NSInteger index = [self.contents indexOfObject:obj];
            UIImage* thumbnail = [self.selectedObjectThumbnails objectForKey:[NSNumber numberWithInteger:index]];
            [self fetchObject:obj withThumbnail:thumbnail success:^(NSDictionary *data) {
                @synchronized(results){
                    [results addObject:data];
                    //Check >= in case we miss (we shouldn't, but hey, better safe than sorry)
                    if (results.count >= totalCount) {
                        hud.labelText = @"Finished uploading";
                        [self finishMultipleUpload:results];
                    } else {
                        hud.labelText = [NSString stringWithFormat:@"Downloading %u of %ld files", results.count + 1, (long)totalCount];
                    }
                }
                @synchronized(progressTracker) {
                    hud.progress = [progressTracker setProgress:1.f forKey:obj];
                }
            } failure:^(NSError *error) {
                NSLog(@"FAIL %@", error);
                [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (error.code == -1009 || error.code == -1001){
                    [self.navigationController popViewControllerAnimated:YES];
                    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                                      message:@"You aren't connected to the internet so we can't get your files."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                    
                    [message show];
                }
                
                [fpdelegate FPSourceControllerDidCancel:self];
            } progress:^(float progress) {
                @synchronized(progressTracker) {
                    hud.progress = [progressTracker setProgress:progress forKey:obj];
                }
            }];
        });
    }
}

- (void) finishMultipleUpload:(NSArray*) results {
    dispatch_async(dispatch_get_main_queue(),^{
        [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [fpdelegate FPSourceController:nil didFinishPickingMultipleMediaWithResults:results];
    });
}


- (void) fetchObject:(NSDictionary*)obj withThumbnail:(UIImage*) thumbnail
             success:(void (^)(NSDictionary *data))success
             failure:(void (^)(NSError *error))failure
            progress:(void (^)(float progress))progress {
    dispatch_async(dispatch_get_main_queue(),^{
        [fpdelegate FPSourceController:self didPickMediaWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              thumbnail, @"FPPickerControllerThumbnailImage"
                                                              , nil]];
    });
    
    NSLog(@"Selected Contents: %@", obj);
    self.view.userInteractionEnabled = NO;
    
    
    BOOL shouldDownload = YES;
    if ([fpdelegate isKindOfClass:[FPPickerController class]]){
        NSLog(@"Should I download?");
        FPPickerController *pickerC = (FPPickerController *)fpdelegate;
        shouldDownload = [pickerC shouldDownload];
    }

    if (shouldDownload){
        NSLog(@"Download");
        [self getObjectInfoAndData:obj success:success failure:failure progress:progress];
    } else {
        NSLog(@"No Download");
        [self getObjectInfo:obj success:success failure:failure progress:progress];
    }
}

- (void) getObjectInfo: (NSDictionary*) obj
               success:(void (^)(NSDictionary *data))success
               failure:(void (^)(NSError *error))failure
              progress:(void (^)(float progress))progress {
    NSURLRequest *request = [self requestForLoadPath:[obj valueForKey:@"link_path"] withFormat:@"fpurl" cachePolicy:NSURLRequestReloadRevalidatingCacheData];
    
    //NSLog(@"request %@", request);
    
    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@" result: %@", JSON);
        
        
        //NSLog(@"Headers: %@", headers);
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [JSON valueForKey:@"url"], @"FPPickerControllerRemoteURL",
                               [JSON valueForKey:@"filename"], @"FPPickerControllerFilename",
                              [JSON valueForKey:@"key"], @"FPPickerControllerKey",
                              nil];
        success(info);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        if (totalBytesExpectedToRead > 0) {
            progress(((float)totalBytesRead)/totalBytesExpectedToRead);
        }
    }];

    [operation start];
    
}


- (void) getObjectInfoAndData: (NSDictionary*) obj
                      success:(void (^)(NSDictionary *data))success
                      failure:(void (^)(NSError *error))failure
                     progress:(void (^)(float progress))progress {

    NSURLRequest *request = [self requestForLoadPath:[obj valueForKey:@"link_path"] withFormat:@"data" cachePolicy:NSURLRequestReloadRevalidatingCacheData];
    
    FPAFHTTPRequestOperation *operation = [[FPAFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPLibrary genRandStringLength:20]];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath isDirectory:NO];
    
    operation.outputStream = [NSOutputStream outputStreamWithURL:tempURL append:NO];
    
    [operation setCompletionBlockWithSuccess:^(FPAFHTTPRequestOperation *operation, id responseObject) {
        NSData *file = [[NSData alloc] initWithContentsOfFile:tempPath];
        NSDictionary *headers = [operation.response allHeaderFields];
        NSString *mimetype = [headers valueForKey:@"Content-Type"];
        // TODO: Should be looking at obj mimetype as well.
        
        if ([mimetype rangeOfString:@";"].location != NSNotFound){
            mimetype = [[mimetype componentsSeparatedByString:@";"] objectAtIndex:0];
        }
        
        UIImage *fileImage;
        if ([FPLibrary mimetype:mimetype instanceOfMimetype:@"image/*"]){
            fileImage = [UIImage imageWithData:file];
        }

        NSString * UTI = [self utiForMimetype:mimetype];

        NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     [headers valueForKey:@"X-Data-Url"], @"FPPickerControllerRemoteURL",
                                     [headers valueForKey:@"X-File-Name"], @"FPPickerControllerFilename",
                                     tempURL, @"FPPickerControllerMediaURL",
                                     UTI, @"FPPickerControllerMediaType",
                                     fileImage, @"FPPickerControllerOriginalImage", //should be last as it might be nil
                                     nil];
        
        if ([headers valueForKey:@"X-Data-Key"] != nil){
            [info setValue:[headers valueForKey:@"X-Data-Key"] forKey:@"FPPickerControllerKey"];
        }
        
        success(info);
    } failure:^(FPAFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        NSLog(@"Get %ld of %ld bytes", (long)totalBytesRead, (long)totalBytesExpectedToRead);
        if (totalBytesExpectedToRead > 0) {
            progress(((float)totalBytesRead)/totalBytesExpectedToRead);
        }
    }];
    
    [operation start];
    
}

- (NSString*) utiForMimetype:(NSString*)mimetype {
    return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                                         (__bridge CFStringRef)mimetype,
                                                                                         NULL);
}

- (NSURLRequest *) requestForLoadPath: (NSString *)loadpath withFormat:(NSString*)type cachePolicy:(NSURLRequestCachePolicy)policy {
    
    return [self requestForLoadPath:loadpath withFormat:type byAppending:@"" cachePolicy:policy];
    
}

- (NSURLRequest *) requestForLoadPath: (NSString *)loadpath withFormat:(NSString*)type byAppending:(NSString*)additionalString cachePolicy:(NSURLRequestCachePolicy)policy {
    
    NSString *appString = [NSString stringWithFormat:@"{\"apikey\": \"%@\"}", fpAPIKEY];
    NSString *js_sessionString = [[NSString stringWithFormat:@"{\"app\": %@, \"mimetypes\": %@}", appString, [sourceType mimetypeString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    NSMutableString *urlString = [NSMutableString stringWithString:[fpBASE_URL stringByAppendingString:[@"/api/path" stringByAppendingString:loadpath ]]]; 

    if ([urlString rangeOfString:@"?"].location == NSNotFound) {
        [urlString appendFormat:@"?format=%@&%@=%@", type, @"js_session", js_sessionString];
    } else {
        [urlString appendFormat:@"&format=%@&%@=%@", type, @"js_session", js_sessionString];
    }
    
    [urlString appendString:additionalString];
    
    //NSLog(@"Loading Contents from URL: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
   
    
    NSMutableURLRequest *mrequest = [NSMutableURLRequest requestWithURL:url cachePolicy:policy timeoutInterval:240];
    [mrequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:fpCOOKIES]];
    
    return mrequest;
    
}


- (void)refresh {
    [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self fpLoadContents:path cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
}

- (void)logout:(NSObject *)button {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/unauth", fpBASE_URL, self.sourceType.identifier];

    NSLog(@"Logout: %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:240];
    [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Logout result: %@", JSON);
        
        [self fpPreloadContents:path cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        
        
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        for (NSHTTPCookie* cookie in [cookies cookies]) {
            NSLog(@"%@",[cookie domain]);
        }

        
        for (NSString *urlString in sourceType.externalDomains){
            NSArray* siteCookies;        
            siteCookies = [cookies cookiesForURL: [NSURL URLWithString:urlString]];
            for (NSHTTPCookie* cookie in siteCookies) {
                [cookies deleteCookie:cookie];
            }
        }
        
        for (NSHTTPCookie* cookie in [cookies cookies]) {
            NSLog(@"- %@",[cookie domain]);
        }
        
        
        [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"error: %@ %@", error, JSON);
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Logout Failure"
                                                          message:@"Hmm. We weren't able to logout."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }];
    [operation start];    
}

- (CGRect)getViewBounds {
    CGRect bounds = self.view.bounds;

    UIView *parent = self.view.superview;
	if (parent) {
		bounds = parent.bounds;
	}
    return bounds;
}

- (void) afterReload {
    return;
}

@end
