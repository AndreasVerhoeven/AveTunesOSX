//
//  AveImageView.m
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/17/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import "AveImageView.h"


@implementation AveImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgColor = [[NSColor clearColor] retain];
        _scaling = NSScaleProportionally;
		
    }
	
    return self;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (BOOL)mouseDownCanMoveWindow
{
	return YES;
}

- (void)dealloc
{
    [_image release];
	[_bgColor release];
    [super dealloc];
}

- (void) setImage:(NSImage*)image
{
    if (_image) {
        [_image autorelease];
        _image = nil;
    }
	
    _image = [image retain];
    [_image setScalesWhenResized:YES];
    [self setNeedsDisplay:YES];
}

- (NSImage*)image
{
    return _image;
}

- (void)setImageScaling:(NSImageScaling)newScaling
{
    _scaling = newScaling;
    [self setNeedsDisplay:YES];
}

- (NSImageScaling)imageScaling
{
    return _scaling;
}

- (void)setBackgroundColor:(NSColor*)color
{
    if (_bgColor) {
        [_bgColor autorelease];
        _bgColor = nil;
    }
	
    _bgColor = [color retain];
    [self setNeedsDisplay:YES];
}

- (NSColor*)backgroundColor
{
    return _bgColor;
}

- (void) drawRect:(NSRect)rects
{
    NSRect bounds = [self bounds];
	
	if(![_bgColor isEqual:[NSColor clearColor]])
	{
		[_bgColor set];
		NSRectFill(bounds);
	}
    
    if (_image) {
        NSImage *copy = [_image copy];
        NSSize size = [copy size];
        float rx, ry, r;
        NSPoint pt;
		
        switch (_scaling) {
            case NSScaleProportionally:
                rx = bounds.size.width / size.width;
                ry = bounds.size.height / size.height;
                r = rx < ry ? rx : ry;
                size.width *= r;
                size.height *= r;
                [copy setSize:size];
                break;
            case NSScaleToFit:
                size = bounds.size;
                [copy setSize:size];
                break;
            case NSScaleNone:
                break;
            default:
                ;
        }
		
        pt.x = 0;//(bounds.size.width - size.width) / 2;
        pt.y = 0;//(bounds.size.height - size.height) / 2;
        
        [copy compositeToPoint:pt operation:NSCompositeSourceOver];
        [copy release];
    }
}

@end
