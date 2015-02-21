//
//  PreferenceWindowController.h
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/18/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DraggableImageView;
@class AveImageView;
@class MAAttachedWindow;
@class BWSelectableToolbar;

@interface PreferenceWindowController : NSWindowController {
	IBOutlet DraggableImageView* desktopImageView;
	IBOutlet DraggableImageView* skinImageView;
	IBOutlet NSPopUpButton* skinsPopup;
	IBOutlet BWSelectableToolbar* toolbar;
	IBOutlet NSView* hint;
	IBOutlet NSTextView* hintText;
	IBOutlet NSTextField* author;
	AveImageView* dragBg;
	AveImageView* fadeBg;
	NSWindow* ref;
	
	MAAttachedWindow* attachedWindow;
	
	BOOL isDragging;
	BOOL didHideSkinPopup;
}

-(IBAction)skinSelected:(NSPopUpButton*)sender;

@end
