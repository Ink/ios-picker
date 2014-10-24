#import "ImageBrowserCell.h"

static void setBundleImageOnLayer(CALayer *layer, CFStringRef imageName)
{
    CGImageRef image = NULL;
    NSString *imageNameString = (__bridge NSString *)imageName;

    NSString *path = [[NSBundle mainBundle] pathForResource:imageNameString.stringByDeletingPathExtension
                                                     ofType:imageNameString.pathExtension];

    if (!path)
    {
        return;
    }

    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath: path], NULL);

    if (!imageSource)
    {
        return;
    }

    image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

    if (!image)
    {
        CFRelease(imageSource);

        return;
    }

    [layer setContents:(__bridge id)image];

    CFRelease(imageSource);
    CFRelease(image);
}

@implementation ImageBrowserCell

- (CALayer *)layerForType:(NSString *)type
{
    CGColorRef color;

    //retrieve some usefull rects
    NSRect frame = [self frame];
    NSRect imageFrame = [self imageFrame];
    NSRect relativeImageFrame = NSMakeRect(imageFrame.origin.x - frame.origin.x, imageFrame.origin.y - frame.origin.y, imageFrame.size.width, imageFrame.size.height);

    /* place holder layer */
    if (type == IKImageBrowserCellPlaceHolderLayer)
    {
        //create a place holder layer
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        CALayer *placeHolderLayer = [CALayer layer];
        placeHolderLayer.frame = *(CGRect *)&relativeImageFrame;

        CGFloat fillComponents[4] = { 1.0, 1.0, 1.0, 0.3 };
        CGFloat strokeComponents[4] = { 1.0, 1.0, 1.0, 0.9 };
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        //set a background color
        color = CGColorCreate(colorSpace, fillComponents);
        [placeHolderLayer setBackgroundColor:color];
        CFRelease(color);

        //set a stroke color
        color = CGColorCreate(colorSpace, strokeComponents);
        [placeHolderLayer setBorderColor:color];
        CFRelease(color);

        [placeHolderLayer setBorderWidth:2.0];
        [placeHolderLayer setCornerRadius:10];
        CFRelease(colorSpace);

        [layer addSublayer:placeHolderLayer];

        return layer;
    }

    /* foreground layer */
    if (type == IKImageBrowserCellForegroundLayer)
    {
        //no foreground layer on place holders
        if ([self cellState] != IKImageStateReady)
        {
            return nil;
        }

        //create a foreground layer that will contain several childs layer
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        NSRect imageContainerFrame = [self imageContainerFrame];
        NSRect relativeImageContainerFrame = NSMakeRect(imageContainerFrame.origin.x - frame.origin.x, imageContainerFrame.origin.y - frame.origin.y, imageContainerFrame.size.width, imageContainerFrame.size.height);

        //add a glossy overlay
        CALayer *glossyLayer = [CALayer layer];
        glossyLayer.frame = *(CGRect *)&relativeImageContainerFrame;
        setBundleImageOnLayer(glossyLayer, CFSTR("glossy.png"));
        [layer addSublayer:glossyLayer];

        //add a pin icon
        CALayer *pinLayer = [CALayer layer];
        setBundleImageOnLayer(pinLayer, CFSTR("pin.tiff"));
        pinLayer.frame = CGRectMake((frame.size.width / 2) - 5, frame.size.height - 17, 24, 30);
        [layer addSublayer:pinLayer];

        return layer;
    }

    /* selection layer */
    if (type == IKImageBrowserCellSelectionLayer)
    {
        //create a selection layer
        CALayer *selectionLayer = [CALayer layer];
        selectionLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        CGFloat fillComponents[4] = { 1.0, 0, 0.5, 0.3 };
        CGFloat strokeComponents[4] = { 1.0, 0.0, 0.5, 1.0 };

        //set a background color
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        color = CGColorCreate(colorSpace, fillComponents);
        [selectionLayer setBackgroundColor:color];
        CFRelease(color);

        //set a border color
        color = CGColorCreate(colorSpace, strokeComponents);
        CFRelease(colorSpace);
        [selectionLayer setBorderColor:color];
        CFRelease(color);

        [selectionLayer setBorderWidth:2.0];
        [selectionLayer setCornerRadius:5];

        return selectionLayer;
    }

    /* background layer */
    if (type == IKImageBrowserCellBackgroundLayer)
    {
        //no background layer on place holders
        if ([self cellState] != IKImageStateReady)
        {
            return nil;
        }

        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        layer.delegate = self;

        NSRect backgroundRect = NSMakeRect(0, 0, frame.size.width, frame.size.height);

        CALayer *photoBackgroundLayer = [CALayer layer];
        photoBackgroundLayer.frame = *(CGRect *)&backgroundRect;

        CGFloat fillComponents[4] = { 0.95, 0.95, 0.95, 1.0 };
        CGFloat strokeComponents[4] = { 0.2, 0.2, 0.2, 0.5 };

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        color = CGColorCreate(colorSpace, fillComponents);
        [photoBackgroundLayer setBackgroundColor:color];
        CFRelease(color);

        color = CGColorCreate(colorSpace, strokeComponents);
        [photoBackgroundLayer setBorderColor:color];
        CFRelease(color);

        [photoBackgroundLayer setBorderWidth:1.0];
        [photoBackgroundLayer setShadowOpacity:0.5];
        [photoBackgroundLayer setCornerRadius:3];

        CFRelease(colorSpace);

        [layer addSublayer:photoBackgroundLayer];
        [layer setNeedsDisplay];

        return layer;
    }

    return [super layerForType:type];
}

- (NSRect)imageFrame
{
    //get default imageFrame and aspect ratio
    NSRect imageFrame = [super imageFrame];

    if (imageFrame.size.height == 0 || imageFrame.size.width == 0)
    {
        return NSZeroRect;
    }

    float aspectRatio =  imageFrame.size.width / imageFrame.size.height;

    // compute the rectangle included in container with a margin of at least 10 pixel at the bottom, 5 pixel at the top and keep a correct  aspect ratio
    NSRect container = [self imageContainerFrame];
    container = NSInsetRect(container, 8, 8);

    if (container.size.height <= 0)
    {
        return NSZeroRect;
    }

    float containerAspectRatio = container.size.width / container.size.height;

    if (containerAspectRatio > aspectRatio)
    {
        imageFrame.size.height = container.size.height;
        imageFrame.origin.y = container.origin.y;
        imageFrame.size.width = imageFrame.size.height * aspectRatio;
        imageFrame.origin.x = container.origin.x + (container.size.width - imageFrame.size.width) * 0.5;
    }
    else
    {
        imageFrame.size.width = container.size.width;
        imageFrame.origin.x = container.origin.x;
        imageFrame.size.height = imageFrame.size.width / aspectRatio;
        imageFrame.origin.y = container.origin.y + container.size.height - imageFrame.size.height;
    }

    //round it
    imageFrame.origin.x = floorf(imageFrame.origin.x);
    imageFrame.origin.y = floorf(imageFrame.origin.y);
    imageFrame.size.width = ceilf(imageFrame.size.width);
    imageFrame.size.height = ceilf(imageFrame.size.height);

    return imageFrame;
}

- (NSRect)imageContainerFrame
{
    NSRect container = [super frame];

    //make the image container 15 pixels up
    container.origin.y += 15;
    container.size.height -= 15;

    return container;
}

- (NSRect)titleFrame
{
    //get the default frame for the title
    NSRect titleFrame = [super titleFrame];

    //move the title inside the 'photo' background image
    NSRect container = [self frame];

    titleFrame.origin.y = container.origin.y + 3;

    //make sure the title has a 7px margin with the left/right borders
    float margin = titleFrame.origin.x - (container.origin.x + 7);

    if (margin < 0)
    {
        titleFrame = NSInsetRect(titleFrame, -margin, 0);
    }

    return titleFrame;
}

- (NSRect)selectionFrame
{
    return NSInsetRect([self frame], -5, -5);
}

@end
