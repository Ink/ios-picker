//#import "ImageBrowserController.h"
//#import "ImageBrowserBackgroundLayer.h"
//#import "Image.h"
//
//@interface ImageBrowserController ()
//
//@property (nonatomic, strong) NSMutableArray *images;
//@property (nonatomic, strong) NSMutableArray *importedImages;
//
//@end
//
//@implementation ImageBrowserController
//
//#pragma mark - Accessors
//
//- (NSMutableArray *)images
//{
//    if (!_images)
//    {
//        _images = [NSMutableArray new];
//    }
//
//    return _images;
//}
//
//- (NSMutableArray *)importedImages
//{
//    if (!_importedImages)
//    {
//        _importedImages = [NSMutableArray new];
//    }
//
//    return _importedImages;
//}
//
//#pragma mark - Public Methods
//
//- (void)awakeFromNib
//{
//    // Allow reordering, animations and set the dragging destination delegate.
//
//    self.imageBrowser.allowsReordering = YES;
//    self.imageBrowser.animates = YES;
//
//    // customize the appearance
//
//    self.imageBrowser.cellsStyleMask = IKCellsStyleTitled | IKCellsStyleOutlined;
//
//    // background layer
//
//    ImageBrowserBackgroundLayer *backgroundLayer = [ImageBrowserBackgroundLayer new];
//
//    self.imageBrowser.backgroundLayer = backgroundLayer;
//
//    backgroundLayer.owner = self.imageBrowser;
//
//    //-- change default font
//    // create a centered paragraph style
//
//    NSMutableParagraphStyle *paraphStyle = [NSMutableParagraphStyle new];
//
//    paraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//    paraphStyle.alignment = NSCenterTextAlignment;
//
//    NSMutableDictionary *attributes = [NSMutableDictionary new];
//
//    attributes[NSFontAttributeName] = [NSFont systemFontOfSize:12];
//    attributes[NSParagraphStyleAttributeName] = paraphStyle;
//    attributes[NSForegroundColorAttributeName] = [NSColor blackColor];
//
//    [self.imageBrowser setValue:attributes
//                         forKey:IKImageBrowserCellsTitleAttributesKey];
//
//    attributes = [NSMutableDictionary new];
//
//    attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:12];
//    attributes[NSParagraphStyleAttributeName] = paraphStyle;
//    attributes[NSForegroundColorAttributeName] = [NSColor whiteColor];
//
//    [self.imageBrowser setValue:attributes
//                         forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
//
//    // change intercell spacing
//
//    self.imageBrowser.intercellSpacing = NSMakeSize(10, 80);
//
//    // change selection color
//
//    [self.imageBrowser setValue:[NSColor colorWithCalibratedRed:1 green:0 blue:0.5 alpha:1.0]
//                         forKey:IKImageBrowserSelectionColorKey];
//
//    // set initial zoom value
//
//    self.imageBrowser.zoomValue = 0.5;
//}
//
//- (void)updateDatasource
//{
//    [self.images addObjectsFromArray:self.importedImages];
//    [self.importedImages removeAllObjects];
//    [self.imageBrowser reloadData];
//}
//
//#pragma mark - Actions
//
//- (IBAction)addImageButtonClicked:(id)sender
//{
////    NSArray* path = openFiles();
////
////    if (path)
////    {
////        // launch import in an independent thread
////        [NSThread detachNewThreadSelector:@selector(addImagesWithPaths:) toTarget:self withObject:path];
////    }
//}
//
//- (IBAction)zoomSliderDidChange:(id)sender
//{
//    // update the zoom value to scale images
//    [self.imageBrowser setZoomValue:[sender floatValue]];
//
//    // redisplay
//    [self.imageBrowser setNeedsDisplay:YES];
//}
//
//#pragma mark - IKImageBrowserDataSource Methods
//
//- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView*)view
//{
//    return self.images.count;
//}
//
//- (id)imageBrowser:(IKImageBrowserView *)view
//       itemAtIndex:(NSUInteger)index
//{
//    return self.images[index];
//}
//
//- (void)    imageBrowser:(IKImageBrowserView*)view
//    removeItemsAtIndexes:(NSIndexSet*)indexes
//{
//    [self.images removeObjectsAtIndexes:indexes];
//}
//
//- (BOOL)  imageBrowser:(IKImageBrowserView *)aBrowser
//    moveItemsAtIndexes:(NSIndexSet *)indexes
//               toIndex:(NSUInteger)destinationIndex;
//{
//    NSUInteger index;
//    NSMutableArray* temporaryArray;
//
//    temporaryArray = [NSMutableArray new];
//
//    // First remove items from the data source and keep them in a temporary array.
//
//    for (index = indexes.lastIndex; index != NSNotFound; index = [indexes indexLessThanIndex:index])
//    {
//        if (index < destinationIndex)
//        {
//            destinationIndex--;
//        }
//
//        id obj = self.images[index];
//        [temporaryArray addObject:obj];
//        [self.images removeObjectAtIndex:index];
//    }
//
//    // Then insert the removed items at the appropriate location.
//
//    NSUInteger n = temporaryArray.count;
//
//    for (index = 0; index < n; index++)
//    {
//        [self.images insertObject:temporaryArray[index]
//                          atIndex:destinationIndex];
//    }
//
//    return YES;
//}
//
//@end
