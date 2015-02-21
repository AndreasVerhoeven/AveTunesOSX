//
//  AvePopupWindowAnimation.h
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/20/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AveImageView;

@interface AvePopupWindowAnimation : NSWindow {
	NSWindow* _window;
	NSRect _rc;
	NSImageView* img;
	int step;
}

-(id)initWitWindow:(NSWindow*)window andFrame:(NSRect)rect;

-(void)zoomIn;

@end
