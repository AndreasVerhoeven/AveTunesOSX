//
//  AvePopupWindowAnimation.m
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/20/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import "AvePopupWindowAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import "AveImageView.h"

@implementation AvePopupWindowAnimation


-(id)initWitWindow:(NSWindow*)window andFrame:(NSRect)rect
{
	NSRect rc = NSMakeRect(0,0, rect.size.width, rect.size.height);
	if ((self = [super initWithContentRect:rc 
								 styleMask:NSBorderlessWindowMask 
								   backing:NSBackingStoreBuffered 
									 defer:NO]))
	{
		_window = window;
		[_window retain];
		_rc = rect;
	
		[self setBackgroundColor:[NSColor clearColor]];
		[self setHasShadow:NO];
		[self setOpaque:NO];
		
		img = [[NSImageView alloc] initWithFrame:rc];
		[[self contentView] addSubview:img];
		
		//NSDisableScreenUpdates();
		// move window offscreen temporarily
		NSPoint origPos = [_window frame].origin;
		[_window setFrameOrigin:NSMakePoint(-200000, -200000)];
		[_window setAlphaValue:1];
		//[_window update];
		CGWindowID windowIds[1] = {[_window windowNumber]};
		CFArrayRef windowIDsArray = CFArrayCreate (kCFAllocatorDefault, (const void **) windowIds, 1, NULL); 
		CGImageRef cgImage = CGWindowListCreateImageFromArray (CGRectNull, windowIDsArray,  kCGWindowImageDefault); 
		
		// Create a bitmap rep from the image...
		NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
		// Create an NSImage and add the bitmap rep to it...
		NSImage *image = [[NSImage alloc] init];
		[image addRepresentation:bitmapRep];
		[bitmapRep release];
		
		[img setImageScaling:NSImageScaleAxesIndependently];
		NSImage* c = [[[NSImage alloc] initWithSize:[image size]] autorelease];
		[c lockFocus];
		[image compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
		[c unlockFocus];
		[img setImage:c];

		[_window setAlphaValue:0];
		[_window setFrameOrigin:origPos];
		//NSEnableScreenUpdates();
		[self setAlphaValue:0];
		
		NSSize size = [image size];
		_rc = NSMakeRect(_rc.origin.x + rc.size.width/2 - size.width/2,
						 _rc.origin.y + rc.size.height/2 - size.height/2 - 4,
						 size.width,
						 size.height);
		[img setFrame:NSMakeRect(0,0, size.width, size.height)];
	}
	
	return self;
}

#define SCALING_FACTOR .10

- (void)showWindowUsingZoomin:(NSRect)targetRect
{
	step = 1;
	
	NSRect rc = [img frame];
	
	float extraWidth = _rc.size.width * SCALING_FACTOR;
	float extraHeight = _rc.size.height * SCALING_FACTOR;
	NSRect startFrom = NSMakeRect(rc.origin.x,// + rc.size.width/2 + extraWidth, 
								  rc.origin.y,// + rc.size.height/2 + extraWidth,
								  _rc.size.width,
								  _rc.size.height);  // <- size component should be {0,0}
	CGFloat duration = .25; // <- make much less in real life like 0.1
	
	[img setFrame:startFrom];
	targetRect = NSInsetRect(targetRect, -extraWidth, -extraHeight);
	[self setFrame:targetRect display:YES];
	//[self setFrame:startFrom display:NO];
	[self makeKeyAndOrderFront:nil];
	
	[img setWantsLayer:YES];
	CAAnimation* animation = [[img animationForKey:@"frameOrigin"] copy];
	[animation setDelegate:self];
	[img setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameOrigin"]];
	
	NSRect frameBigger = NSMakeRect(0,0, rc.size.width+extraWidth*2, rc.size.height+extraHeight*2);
	[img setFrame:frameBigger];
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:duration];
	
	[[img animator] setFrame:NSMakeRect(extraWidth,extraHeight, _rc.size.width, _rc.size.height)];
	[[self animator] setAlphaValue:1.0];
	[NSAnimationContext endGrouping];
	
	
	
}

-(void)animateBack:(id)unused
{
	float extraWidth = _rc.size.width * SCALING_FACTOR;
	float extraHeight = _rc.size.height * SCALING_FACTOR;
	
	CAAnimation* animation = [[img animationForKey:@"frameOrigin"] copy];
	[animation setDelegate:self];
	[img setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameOrigin"]];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:.05];
	
	[[img animator] setFrame:NSMakeRect(extraWidth,extraHeight, _rc.size.width, _rc.size.height)];
	[NSAnimationContext endGrouping];	
}

- (void)animationDidStop:(id)arg finished:(BOOL)flag 
{
	NSLog(@"called %d", img.frame.size.width);
	//if(img.frame.size.width != self.frame.size.width+40)return;
	if(step == 0)
	{
		[self performSelectorOnMainThread:@selector(animateBack:) withObject:nil waitUntilDone:NO];
		step++;
	}
	else
	{
		[_window setAlphaValue:1];
		[self setIsVisible:NO];
		
	}

}

-(void)zoomIn
{
	[self showWindowUsingZoomin:_rc];
}

-(void)dealloc
{
	[_window release];
	[super dealloc];
}

@end
