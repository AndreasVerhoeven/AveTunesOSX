//
//  PreferenceWindowController.m
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/18/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import "PreferenceWindowController.h"
#import "AveTunes1AppDelegate.h"
#import "MainWindowController.h"
#import "AveImageView.h"
#import "MAAttachedWindow.h"
#import "BWToolkitFramework/BWToolkitFramework.h"
#import "IniFile.h"
#import <QuartzCore/CoreAnimation.h>
#import "AvePopupWindowAnimation.h"

@interface DraggableImageView : NSImageView
{
	id target;
	SEL selector;
}

@property (retain) id target;
@property (assign) SEL selector;

@end

@implementation DraggableImageView

@synthesize target, selector;

-(void)mouseDragged:(NSEvent *)theEvent
{
	[target performSelector:selector withObject:theEvent];
}

@end



@implementation PreferenceWindowController


void GetDesktopWindowIds(CGWindowID* ids)
{
	CFArrayRef ar = CGWindowListCopyWindowInfo (kCGWindowListOptionOnScreenOnly, kCGNullWindowID); 
	
	CGWindowID desktopId = kCGNullWindowID;
	CGWindowID iconsId = kCGNullWindowID;
	for (CFIndex i = 0; i <CFArrayGetCount (ar); i ++)
	{
		CFDictionaryRef window = CFArrayGetValueAtIndex (ar, i);
		NSString * name = (NSString *) CFDictionaryGetValue (window, kCGWindowName); 
		NSString * owner_name = (NSString *) CFDictionaryGetValue (window, kCGWindowOwnerName); 
		if ([name isEqualToString: @ "Desktop"] && [owner_name isEqualToString: @ "Window Server"])
		{
			CFNumberGetValue (CFDictionaryGetValue (window, kCGWindowNumber), 
							  kCGWindowIDCFNumberType, & desktopId); 	
		}
		else if ([name isEqualToString: @ ""] && [owner_name isEqualToString: @ "Finder"])
		{
			CFNumberGetValue (CFDictionaryGetValue (window, kCGWindowNumber), 
							  kCGWindowIDCFNumberType, & iconsId); 	
		}
	}
	
	ids[1] = desktopId;
	ids[0] = iconsId;
}

-(void)updateDesktopImageView
{
	NSRect rc = [desktopImageView bounds];
	rc.origin=[desktopImageView convertPoint:rc.origin toView:nil];
	rc.origin=[[self window] convertBaseToScreen:rc.origin];
	rc.origin.y = [[NSScreen mainScreen] frame].size.height - rc.origin.y - rc.size.height;
	
	CGWindowID desktopIds[2] = {0};
	GetDesktopWindowIds(desktopIds);
	CFArrayRef windowIDsArray = CFArrayCreate (kCFAllocatorDefault, (const void **) desktopIds, 2, NULL); 
	CGImageRef cgImage = CGWindowListCreateImageFromArray (NSRectToCGRect(rc), windowIDsArray, kCGWindowImageDefault); 
	
	// Create a bitmap rep from the image...
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
	// Create an NSImage and add the bitmap rep to it...
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:bitmapRep];
	[bitmapRep release];
	
	if(desktopImageView.image == nil)
		[desktopImageView setImage:image];
	else
	{
			

		if(nil == fadeBg)
		{
			fadeBg = [[AveImageView alloc] initWithFrame:[desktopImageView frame]];
			[[skinImageView superview] addSubview:fadeBg positioned:NSWindowAbove relativeTo:desktopImageView];
			[fadeBg setBackgroundColor: [NSColor selectedMenuItemColor]];
		}
		
		fadeBg.image = image;
		[fadeBg setHidden:NO];
		[fadeBg setAlphaValue:0];
		[fadeBg.animator setAlphaValue:1];
		
		[self performSelector:@selector(swapImages:) withObject:nil afterDelay:0.5];
	}
}

-(void)swapImages:(id)unused
{
	if(fadeBg.image != nil)
	{
		NSImage* img = fadeBg.image;
		fadeBg.image = nil;
		desktopImageView.image = img;
		[fadeBg setHidden:YES];
	}
}

-(void)fillSkins
{
	NSArray* skins = [AveTunes1AppDelegate skins];
	[skinsPopup removeAllItems];
	[skinsPopup addItemsWithTitles:skins];
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* skin = [defaults stringForKey:@"skin"];
	skin = [[skin componentsSeparatedByString:@"/"] objectAtIndex:0];
	[skinsPopup selectItemWithTitle:skin];
}

-(void)updateSkinPreview
{
	NSMenuItem* item = [skinsPopup selectedItem];
	NSString* skin = [item title];
	NSString* path = [AveTunes1AppDelegate pathForSkin:skin];
	NSString* bgPath = [path stringByAppendingPathComponent:@"images/bg.png"];
	NSImage* image = [[[NSImage alloc] initWithContentsOfFile:bgPath] autorelease];
	
	IniFile* ini = [IniFile iniFileWithContentsOfFile:[path stringByAppendingPathComponent:@"skin.ini"]];
	[author setStringValue:[NSString stringWithFormat:@"%@", [ini getString:@"author" inSection:@"info" withDefault:@""]]];
	
	/*
	AveTunes1AppDelegate* app = (AveTunes1AppDelegate*)[[NSApplication sharedApplication] delegate];
	CGWindowID windowId = [app.window windowNumber];
	NSRect rc = [app.window frame];
	rc.origin.x = 0;
	rc.origin.y = 0;
	
	rc.origin=[[app window] convertBaseToScreen:rc.origin];
	rc.origin.y = [[NSScreen mainScreen] frame].size.height - rc.origin.y - rc.size.height;
	CFArrayRef windowIDsArray = CFArrayCreate (kCFAllocatorDefault, (const void **) &windowId, 1, NULL); 
	CGImageRef cgImage = CGWindowListCreateImageFromArray (NSRectToCGRect(rc), windowIDsArray, kCGWindowImageDefault); 
	
	// Create a bitmap rep from the image...
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
	// Create an NSImage and add the bitmap rep to it...
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:bitmapRep];
	[bitmapRep release];
	 */
	
	[skinImageView setImage:image];
}

-(void)onDragStart:(NSEvent*)theEvent
{
	if([attachedWindow alphaValue] != 0)
		[attachedWindow.animator setAlphaValue:0];
	
	NSMenuItem* item = [skinsPopup selectedItem];
	NSString* skin = [item title];
	NSString* path = [AveTunes1AppDelegate pathForSkin:skin];
	
	NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	NSArray *fileList = [NSArray arrayWithObjects:path, nil];
    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType]
				   owner:nil];
    [pboard setPropertyList:fileList forType:NSFilenamesPboardType];
	
	[skinImageView lockFocus];
	
	//NSBitmapImageRep* bitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect: [skinImageView bounds]] autorelease];
	//[skinImageView unlockFocus];
	
	
	NSImage* image = [[[NSImage alloc] initWithSize:[skinImageView bounds].size] autorelease];

	//[image addRepresentation:bitmap];
	[image lockFocus];
	//[[NSColor redColor] set];
	//NSRectFill([skinImageView bounds]);
	NSImage* copy = [skinImageView image];
	NSSize size = [copy size];
	float rx, ry, r;
	NSPoint pt;
	

	rx = skinImageView.bounds.size.width / size.width;
	ry = skinImageView.bounds.size.height / size.height;
	r = rx < ry ? rx : ry;
	NSSize realSize = [copy size];
	size.width *= r;
	size.height *= r;
	[copy setSize:size];

	
	pt.x = (skinImageView.bounds.size.width/2 - realSize.width/2) ;
	pt.y = (skinImageView.bounds.size.height/2 - realSize.height/2);
	
	 //[copy compositeToPoint:pt operation:NSCompositeSourceOver];
	 [copy dissolveToPoint:pt fraction:0.5];
	[copy setSize:realSize];
	
	[image unlockFocus];

	[skinImageView.animator setAlphaValue:0.5];
	isDragging = YES;
	
	NSPoint point = [skinImageView convertPointFromBase:[theEvent locationInWindow]];
	[skinImageView dragImage:image at:NSMakePoint(0,0) offset:NSMakeSize(point.x, point.y) event:theEvent pasteboard:pboard source:self slideBack:YES];
	
	isDragging = NO;
	
	NSFileManager* fileManager = [NSFileManager defaultManager]; 
	if([fileManager fileExistsAtPath:path])
	{
		[skinImageView setAlphaValue:1];
	}
	else
	{
		[skinImageView.animator setAlphaValue:0];
		
		[self fillSkins];
		[skinsPopup selectItemAtIndex:0];
		[self performSelector:@selector(skinSelected:) withObject:skinsPopup afterDelay:0.5];
	}

}


-(void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	if(operation == NSDragOperationDelete)
	{
		NSMenuItem* item = [skinsPopup selectedItem];
		NSString* skin = [item title];
		NSString* path = [AveTunes1AppDelegate pathForSkin:skin];
		
		NSArray *files = [NSArray arrayWithObject:[[path pathComponents] lastObject]];
		NSString *sourceDir = [path stringByDeletingLastPathComponent]; 
		NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
		int tag;
		
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
													 source:sourceDir destination:trashDir files:files tag:&tag];
	}
}



- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
	return NSDragOperationDelete;//NSDragOperationMove | NSDragOperationDelete;
}



//Destination Operations
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if([attachedWindow alphaValue] != 0)
		[attachedWindow.animator setAlphaValue:0];
	
	if(isDragging)
		return NSDragOperationNone;
		
	//NSDragOperation sourceDragMask  = [sender draggingSourceOperationMask];
	NSPasteboard* pasteboard = [sender draggingPasteboard];
	if([[pasteboard types] containsObject:NSFilenamesPboardType])
	{
		BOOL valid = NO;
		NSFileManager* fileManager = [NSFileManager defaultManager];
		NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
		for(NSString* file in files)
		{
			BOOL isDir = YES;
			if([fileManager fileExistsAtPath:file isDirectory:&isDir] && isDir)
			{
				valid = YES;
				break;
			}
		}
		
		if(valid)
		{
			if(nil == dragBg)
			{
				dragBg = [[AveImageView alloc] initWithFrame:[skinImageView frame]];
				[[skinImageView superview] addSubview:dragBg];
				//[dragBg setBackgroundColor: [NSColor selectedMenuItemColor]];
				NSImage* img = [[[NSImage alloc] initWithSize:dragBg.frame.size] autorelease];
				[img lockFocus];
				NSBezierPath* path1 = [NSBezierPath bezierPathWithRect:dragBg.bounds];
				[path1 setLineWidth:8];	
				
				// draw the path
				//[inner set];[path1 fill];	
				[[NSColor selectedTextBackgroundColor] set];[path1 stroke];
				[img unlockFocus];
				
				dragBg.image = img;
			}
			
			[dragBg setAlphaValue:0];
			//[dragBg setFrame:[bg frame]];
			
			[dragBg.animator setAlphaValue:1.0];
			return NSDragOperationMove;//return sourceDragMask & NSDragOperationMove != 0 ? NSDragOperationMove : NSDragOperationCopy;						
		}
	}
	
	return NSDragOperationNone;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	[dragBg.animator setAlphaValue:0];
}

//Destination Operations
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	//NSDragOperation sourceDragMask  = [sender draggingSourceOperationMask];
	NSPasteboard* pasteboard = [sender draggingPasteboard];
	if([[pasteboard types] containsObject:NSFilenamesPboardType])
	{
		BOOL valid = NO;
		NSFileManager* fileManager = [NSFileManager defaultManager];
		NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
		NSString* skinToSet = nil;
		for(NSString* file in files)
		{
			BOOL isDir = YES;
			if([fileManager fileExistsAtPath:file isDirectory:&isDir] && isDir)
			{
				NSString* name = [[file pathComponents] lastObject];
				NSString *dest = @"~/Library/Application Support/AveTunes/";
				dest = [dest stringByExpandingTildeInPath];
				dest = [dest stringByAppendingPathComponent:name];
				//if(sourceDragMask & NSDragOperationMove != 0)
				[fileManager moveItemAtPath:file toPath:dest error:nil];
				//else 
				//	[fileManager copyItemAtPath:file toPath:dest error:nil];
				
				valid = YES;
				
				if(skinToSet == nil)
					skinToSet = name;
			}
		}
		
		[self fillSkins];
		
		if(skinToSet)
		{
			[skinsPopup selectItemWithTitle:skinToSet];
			[self skinSelected:skinsPopup];
		}
		
		if(valid)
		{
			[dragBg.animator setAlphaValue:0];
			return YES;					
		}
	}
	
	[dragBg.animator setAlphaValue:0];
	return NO;
}

typedef void * CGSConnectionID;
extern OSStatus CGSNewConnection(const void **attr, CGSConnectionID *id);

- (void)enableBlurForWindow:(NSWindow *)window
{
	
	CGSConnectionID _myConnection;
	uint32_t __compositingFilter;
	
	int __compositingType = 1; // Apply filter to contents underneath the window, then draw window normally on top
	
	/* Make a new connection to CoreGraphics, alternatively you could use the main connection*/
	
	CGSNewConnection(NULL , &_myConnection);
	
	/* The following creates a new CoreImage filter, then sets its options with a dictionary of values*/
	
	CGSNewCIFilterByName (_myConnection, (CFStringRef)@"CIGaussianBlur", &__compositingFilter);
	NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:@"inputRadius"];
	CGSSetCIFilterValuesFromDictionary(_myConnection, __compositingFilter, (CFDictionaryRef)optionsDict);
	
	/* Now just switch on the filter for the window */
	
	CGSAddWindowFilter(_myConnection, [window windowNumber], __compositingFilter, __compositingType );
}

- (void)awakeFromNib
{
	desktopImageView.selector = @selector(onDragStart:);
	desktopImageView.target = self;

	skinImageView.selector = @selector(onDragStart:);
	skinImageView.target = self;
	
	[self updateDesktopImageView];
	[self fillSkins];
	[self updateSkinPreview];
	[self.window center];
	
	[self.window registerForDraggedTypes:[NSArray arrayWithObjects:@"public.directory", NSFilenamesPboardType, nil]];
	[desktopImageView unregisterDraggedTypes];
	[skinImageView unregisterDraggedTypes];
	
	NSPoint pt = [skinImageView convertPointToBase:[skinImageView frame].origin];
	pt.x += 10;//skinImageView.frame.size.width - 20;
	//pt.y -= 20;
	//pt.y -= skinImageView.frame.size.height / 2;
	pt = [[self window] convertBaseToScreen:pt];
	
	NSCursor *customLinkCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"linkCursor.png"] 					  hotSpot:NSMakePoint(0, 0)];
	NSDictionary *customLinkTextAttributes
    = [NSDictionary dictionaryWithObjectsAndKeys:
						customLinkCursor,NSCursorAttributeName,
						[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,
						nil];
	[customLinkCursor release];
	customLinkCursor = nil;
	
	[hintText setAutomaticLinkDetectionEnabled:YES];
	[hintText setLinkTextAttributes:customLinkTextAttributes];
	
	attachedWindow = [[MAAttachedWindow alloc] initWithView:hint attachedToPoint:pt onSide:MAPositionLeft];
	[attachedWindow setIgnoresMouseEvents:NO];
	[attachedWindow display];
	[attachedWindow setHasShadow:NO];
	[attachedWindow setHasShadow:YES];
	[self enableBlurForWindow:attachedWindow];
	[attachedWindow orderFront:self];
	[self.window addChildWindow:attachedWindow ordered:NSWindowAbove]; 
	//[attachedWindow setAutodisplay:YES];
	attachedWindow.alphaValue = 0;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paneSwitch:) name:@"BWSelectableToolbarItemClicked" object:toolbar];
	
	NSString* selItem = [toolbar selectedItemIdentifier];
	if([[[[toolbar items] objectAtIndex:1] itemIdentifier] isEqualToString:selItem])
	{
		[attachedWindow.animator setAlphaValue:1];
		[[self window] setContentBorderThickness:45.0 forEdge:NSMinYEdge];
	}
}

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{

    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
	
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
	
	float wiggle = 3;
	frame = NSMakeRect(frame.origin.x, frame.origin.y, wiggle, wiggle);
	//CGPathAddEllipseInRect(shakePath, NULL, NSRectToCGRect(frame));
	CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + wiggle, NSMinY(frame));
	CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + wiggle, NSMinY(frame) + wiggle);
	CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame)+wiggle);
	//CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + wiggle, NSMinY(frame));
	
	
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = 0.75;
	shakeAnimation.repeatCount = 8;
	shakeAnimation.speed = 1.5;
    return shakeAnimation;
}


-(void)paneSwitch:(NSNotification*)notification
{
	NSToolbarItem* item = [[notification userInfo] objectForKey:@"BWClickedItem"];
	
	if(item == [[toolbar items] objectAtIndex:1])
	{
		//[attachedWindow setAnimations:[NSDictionary dictionaryWithObject:[self shakeAnimation:[attachedWindow frame]] forKey:@"frameOrigin"]];
		//[[attachedWindow animator] setFrameOrigin:[attachedWindow frame].origin];
		//[attachedWindow.animator setAlphaValue:1];
		
		NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
		int numSkinsShowed  = [def integerForKey:@"numSkinsShowed"];
		if(!didHideSkinPopup && numSkinsShowed < 5)
		{
			[attachedWindow update];
			NSRect frame = [attachedWindow frame];
			
			AvePopupWindowAnimation* anim = [[AvePopupWindowAnimation alloc] initWitWindow:attachedWindow andFrame:frame];
			[anim zoomIn];
			ref = anim;
			
			[def setInteger:numSkinsShowed+1 forKey:@"numSkinsShowed"];
			[def synchronize];
		}
		
		[[self window] setContentBorderThickness:45.0 forEdge:NSMinYEdge];
	}
	else
	{
		didHideSkinPopup = YES;
		[attachedWindow.animator setAlphaValue:0];
		
		[[self window] setContentBorderThickness:0 forEdge:NSMinYEdge];
	}

}


-(IBAction)skinSelected:(NSPopUpButton*)sender
{
	NSMenuItem* item = [skinsPopup selectedItem];
	NSString* skin = [item title];
	
	AveTunes1AppDelegate* app = (AveTunes1AppDelegate*)[[NSApplication sharedApplication] delegate];
	MainWindowController* c = (MainWindowController*)[app.window delegate];
	[c selectNewSkin:skin];
	
	[self updateSkinPreview];
	[skinImageView.animator setAlphaValue:1];
	
	if([attachedWindow alphaValue] != 0)
		[attachedWindow.animator setAlphaValue:0];
}


- (void)windowDidMove:(NSNotification*)notification { 
	[self updateDesktopImageView];
}
@end
