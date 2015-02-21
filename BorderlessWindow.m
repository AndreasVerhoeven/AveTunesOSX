//
//  BorderlessWindow.m
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import "BorderlessWindow.h"

@implementation BorderlessWindow

@synthesize initialLocation;

/*
 In Interface Builder, the class for the window is set to this subclass. Overriding the initializer provides a mechanism for controlling how objects of this class are created.
 */
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    // Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        // Start with no transparency for all drawing into the window
        [self setAlphaValue:1.0];
        // Turn off opacity so that the parts of the window that are not drawn into are transparent.
        [self setOpaque:NO];
		[self setLevel:kCGDesktopWindowLevel + 1];
		[self setBackgroundColor:[NSColor clearColor]];
		//[self.contentView setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

/*
 Custom windows that use the NSBorderlessWindowMask can't become key by default. Override this method so that controls in this window will be enabled.
 */
- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

/*
 Start tracking a potential drag operation here when the user first clicks the mouse, to establish the initial location.
 */
- (void)mouseDown:(NSEvent *)theEvent {    
    // Get the mouse location in window coordinates.
	//if([[self delegate] onMouseDown:theEvent])
	//	return;
	
	inMove = NO;
    self.initialLocation = [theEvent locationInWindow];
}

-(void)mouseUp:(NSEvent *)theEvent
{
	if(!inMove)
		[super mouseUp:theEvent];
}

/*
 Once the user starts dragging the mouse, move the window with it. The window has no title bar for the user to drag (so we have to implement dragging ourselves)
 */
- (void)mouseDragged:(NSEvent *)theEvent {
	
	inMove = YES;
	
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;
	
    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    // Update the origin with the difference between the new mouse location and the old mouse location.
    newOrigin.x += (currentLocation.x - initialLocation.x);
    newOrigin.y += (currentLocation.y - initialLocation.y);
	
    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
		//XXX     newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    
    // Move the window to the new location
    [self setFrameOrigin:newOrigin];
}

@end
