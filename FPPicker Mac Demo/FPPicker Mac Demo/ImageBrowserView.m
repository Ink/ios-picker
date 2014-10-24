#import "ImageBrowserView.h"
#import "ImageBrowserCell.h"


@implementation ImageBrowserView

- (IKImageBrowserCell *)newCellForRepresentedItem:(id)cell
{
    return [ImageBrowserCell new];
}

- (void)drawRect:(NSRect)rect
{
    //retrieve the visible area
    NSRect visibleRect = [self visibleRect];

    //compare with the visible rect at the previous frame
    if (!NSEqualRects(visibleRect, lastVisibleRect))
    {
        //we did scroll or resize, redraw the background
        [[self backgroundLayer] setNeedsDisplay];

        //update last visible rect
        lastVisibleRect = visibleRect;
    }

    [super drawRect:rect];
}

@end
