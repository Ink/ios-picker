#import "ImageBrowserBackgroundLayer.h"

@implementation ImageBrowserBackgroundLayer

@synthesize owner;

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        //needs to redraw when bounds change
        self.needsDisplayOnBoundsChange = YES;
    }

    return self;
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    return nil;
}

- (void)drawInContext:(CGContextRef)context
{
    //retrieve bounds and visible rect

    NSRect visibleRect = [owner visibleRect];
    NSRect bounds = [owner bounds];

    //retrieve background image

    CGImageRef image = NULL;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"metal_background"
                                                     ofType:@"tif"];

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

    float width = (float) CGImageGetWidth(image);
    float height = (float) CGImageGetHeight(image);

    //compute coordinates to fill the view
    float left, top, right, bottom;

    top = bounds.size.height - NSMaxY(visibleRect);
    top = fmod(top, height);
    top = height - top;

    right = NSMaxX(visibleRect);
    bottom = -height;

    // tile the image and take in account the offset to 'emulate' a scrolling background

    for (top = visibleRect.size.height - top; top > bottom; top -= height)
    {
        for (left = 0; left<right; left += width)
        {
            CGContextDrawImage(context, CGRectMake(left, top, width, height), image);
        }
    }

    CFRelease(imageSource);
    CFRelease(image);
}

@end
