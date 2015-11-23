//
//  FPLocalAlbumController.m
//  FPPicker
//
//  Created by Liyan David Chang on 4/17/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import "FPLocalAlbumController.h"
#import "FPLocalController.h"
#import "FPTableViewCell.h"

@import Photos;

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
    [super viewWillAppear:animated];

    self.tableView.frame = self.view.bounds;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // Fix #104: Request authorization for the Photo Library, if the app has not already done so
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Retry loading the images. Dispatch onto the main thread, since this block
                // will be called from a background thread.
                [self loadAlbumData];
            });
        }];

        // Wait until after the user has responded to the prompt.
        return;
    } else {
        // The user has already responded to the authorization request
        [self loadAlbumData];
    }
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
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.text = @"No Albums Available";

    // collect the things

    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *predicateComponents = [NSMutableArray array];
    NSMutableArray *arguments = [NSMutableArray array];

    if (showImages)
    {
        [predicateComponents addObject:@"(mediaType == %d)"];
        [arguments addObject:@(PHAssetMediaTypeImage)];
    }

    if (showVideos)
    {
        [predicateComponents addObject:@"(mediaType == %d)"];
        [arguments addObject:@(PHAssetMediaTypeVideo)];
    }

    NSString *predicateFormat = [predicateComponents componentsJoinedByString:@" || "];

    PHFetchOptions *fetchOptions = [PHFetchOptions new];

    fetchOptions.predicate = [NSPredicate predicateWithFormat:predicateFormat
                                                argumentArray:arguments];

    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAny
                                                                         options:nil];

    [userAlbums enumerateObjectsUsingBlock: ^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection
                                                                         options:fetchOptions];

        if (assetsFetchResult.count > 0)
        {
            [collector addObject:collection];
        }
    }];

    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                          options:nil];

    [smartAlbums enumerateObjectsUsingBlock: ^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection
                                                                         options:fetchOptions];

        if (assetsFetchResult.count > 0)
        {
            [collector addObject:collection];
        }
    }];

    [self setAlbums:collector];
    [self.tableView reloadData];
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
        [self.tableView addSubview:_emptyLabel];
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

    FPTableViewCell *cell = [passedTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[FPTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier :CellIdentifier];
    }

    // Get count
    PHAssetCollection *collection = (PHAssetCollection *)self.albums[indexPath.row];
    PHFetchOptions *fetchOptions = [PHFetchOptions new];

    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                                   ascending:NO]];

    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection
                                                                     options:fetchOptions];

    NSUInteger collectionTotalCount = assetsFetchResult.count;

    if (collectionTotalCount > 0)
    {
        PHAsset *asset = assetsFetchResult[0];

        [FPUtils asyncFetchAssetThumbnailFromPHAsset:asset
                                          completion: ^(UIImage *image) {
            cell.imageView.image = image;
        }];

        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", collection.localizedTitle, (unsigned long)collectionTotalCount];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        UIView *bgColorView = [UIView new];
        bgColorView.backgroundColor = [FPTableViewCell appearance].selectedBackgroundColor;
        cell.selectedBackgroundView = bgColorView;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FPLocalController *sView = [FPLocalController new];

    sView.assetCollection = (PHAssetCollection *)self.albums[indexPath.row];
    sView.fpdelegate = self.fpdelegate;
    sView.selectMultiple = self.selectMultiple;
    sView.maxFiles = self.maxFiles;
    sView.source = self.source;

    [self.navigationController pushViewController:sView
                                         animated:YES];
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
