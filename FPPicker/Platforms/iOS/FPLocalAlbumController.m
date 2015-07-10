//
//  FPLocalAlbumController.m
//  FPPicker
//
//  Created by Liyan David Chang on 4/17/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import "FPLocalAlbumController.h"
#import "FPLocalController.h"

@interface FPLocalAlbumController ()

@property UILabel *emptyLabel;

@end

@implementation FPLocalAlbumController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.view addSubview:self.tableView];
    self.title = _source.name;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.frame = self.view.bounds;
    [self loadAlbumData];

    [super viewWillAppear:animated];
}

- (void)loadAlbumData
{
    BOOL showImages;
    BOOL showVideos;

    NSArray *requestedTypes = _source.mimetypes;

    NSLog(@"Requested %@", requestedTypes);

    [self shouldShowImagesAndVideoForMimetypes:requestedTypes
                                  resultImages:&showImages
                                  resultVideos:&showVideos];

    NSLog(showImages ? @"Images: Yes" : @"Images: No");
    NSLog(showVideos ? @"Videos: Yes" : @"Videos: No");

    CGRect bounds = self.view.bounds;

    // Just make one instance empty label

    _emptyLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                             CGRectGetMidY(bounds) - 60,
                                                             CGRectGetWidth(bounds),
                                                             30)];
    _emptyLabel.textColor = [UIColor grayColor];
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.text = @"No Albums Available";

    // collect the things

    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [FPLocalAlbumController defaultAssetsLibrary];

    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationResultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (!group)
        {
            // We're done, so reload data

            [self setAlbums:collector];
            [self.tableView reloadData];

            return;
        }

        NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
        NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];

        NSLog(@"GROUP: %@ %lu", sGroupPropertyName, (unsigned long)nType);

        if (showImages && !showVideos)
        {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        else if (showVideos && !showImages)
        {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        }

        if(group.numberOfAssets == 0){
            return;
        }
        
        if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] &&
            nType == ALAssetsGroupSavedPhotos)
        {
            [collector insertObject:group
                            atIndex:0];
        }
        else
        {
            [collector addObject:group];
        }
    };

    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"There was an error with the ALAssetLibrary: %@", error);
    };

    [al enumerateGroupsWithTypes:ALAssetsGroupAll
                      usingBlock:enumerationResultsBlock
                    failureBlock:failureBlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAlbums:(NSArray *)albums
{
    if (_albums != albums)
    {
        _albums = albums;
    }

    // In theory, you should be able to do this only if you update.
    // However, this seems safer to make sure that the empty label gets removed.

    if (_albums.count == 0)
    {
        [self.view addSubview:_emptyLabel];
    }
    else
    {
        [_emptyLabel removeFromSuperview];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)passedTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [passedTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    // Get count
    ALAssetsGroup *g = (ALAssetsGroup *)self.albums[indexPath.row];

    UIImage *albumImage = [UIImage imageWithCGImage:((ALAssetsGroup *)self.albums[indexPath.row]).posterImage];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [g valueForProperty:ALAssetsGroupPropertyName], (long)[g numberOfAssets]];
    [cell.imageView setImage:albumImage];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FPLocalController *sView = [FPLocalController new];

    sView.assetGroup = (ALAssetsGroup *)self.albums[indexPath.row];
    sView.fpdelegate = self.fpdelegate;
    sView.selectMultiple = self.selectMultiple;
    sView.maxFiles = self.maxFiles;
    sView.source = self.source;

    [self.navigationController pushViewController:sView
                                         animated:YES];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;

    dispatch_once(&pred, ^{
        library = [ALAssetsLibrary new];
    });

    return library;
}

#pragma mark - Private

- (void)shouldShowImagesAndVideoForMimetypes:(NSArray *)mimeTypes
                                resultImages:(BOOL *)shouldShowImages
                                resultVideos:(BOOL *)shouldShowVideos
{
    *shouldShowVideos = NO;
    *shouldShowImages = NO;

    if ([mimeTypes containsObject:@"video/quicktime"] ||
        [mimeTypes containsObject:@"video/*"])
    {
        *shouldShowVideos = YES;
    }

    if ([mimeTypes containsObject:@"image/png"] ||
        [mimeTypes containsObject:@"image/jpeg"] ||
        [mimeTypes containsObject:@"image/*"])
    {
        *shouldShowImages = YES;
    }

    if ([mimeTypes containsObject:@"*/*"])
    {
        *shouldShowImages = YES;
        *shouldShowVideos = YES;
    }
}

@end
