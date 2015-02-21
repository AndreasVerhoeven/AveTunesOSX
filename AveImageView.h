//
//  AveImageView.h
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/17/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AveImageView : NSView {
	NSImage *_image;
	NSColor *_bgColor;
	NSImageScaling _scaling;
}
- (void)setImage:(NSImage*)image;
- (void)setImageScaling:(NSImageScaling)newScaling;
- (void)setBackgroundColor:(NSColor*)color;
- (NSImage*)image;
- (NSColor*)backgroundColor;
- (NSImageScaling)imageScaling;

@end
