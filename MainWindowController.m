//
//  MainWindowController.m
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import "MainWindowController.h"
#import "IniFile.h"
#import "AveImageView.h"
#import "iTunes.h"
#import "AveTunes1AppDelegate.h"

@implementation MainWindowController

#define DIR_LEFT_RIGHT 0
#define DIR_RIGHT_LEFT 1
#define DIR_TOP_BOTTOM 2
#define DIR_BOTTOM_TOP 3

NSRect NSRectToInts(NSRect rc)
{
	rc.origin.x = floor(rc.origin.x);
	rc.origin.y = floor(rc.origin.y);
	rc.size.width = floor(rc.size.width);
	rc.size.height = floor(rc.size.height);
	
	return rc;
}

-(NSColor*)colorFromIni:(NSString*)sectionName
{
	int a = [ini getInt:@"ColorA" inSection:sectionName withDefault:255];
	int r = [ini getInt:@"ColorR" inSection:sectionName withDefault:255];
	int g = [ini getInt:@"ColorG" inSection:sectionName withDefault:255];
	int b = [ini getInt:@"ColorB" inSection:sectionName withDefault:255];
	
	return [NSColor colorWithCalibratedRed:((float)r)/255.0 green:(float)(g)/255.0 blue:(float)(b)/255.0 alpha:(float)(a)/255.0];
}

-(NSRect)rectFromIni:(NSString*)sectionName
{
	int left   = [ini getInt:@"left"   inSection:sectionName withDefault:0];
	int top    = [ini getInt:@"top"    inSection:sectionName withDefault:0];
	int width  = [ini getInt:@"Width"  inSection:sectionName withDefault:0];
	int height = [ini getInt:@"Height" inSection:sectionName withDefault:0];
	int size   = [ini getInt:@"Size"   inSection:sectionName withDefault:0];
	
	if(height != 0)
		height = MAX(size+4, height);
	
	return NSMakeRect(left, top, width, height);
}

-(void)placeView:(NSView *)viewArg fromRect:(NSRect)rc
{
	NSView* superView = [viewArg superview];
	NSRect parentFrame = [superView frame];
	rc.origin.y = parentFrame.size.height - rc.origin.y - rc.size.height;
	if(rc.size.width == 0 || rc.size.height == 0)
	{
		[viewArg setHidden:YES];
	}
	else
	{
		[viewArg setHidden:NO];
	}

	[viewArg setFrame:rc];
}

-(void)placeView:(NSView*)viewArg fromIni:(NSString*)sectionName
{
	NSRect rc = [self rectFromIni:sectionName];
	[self placeView:viewArg fromRect:rc];
}

-(void)updateSoundVolume: (int)volume
{
	float ratio = (float)volume / 100;
	int direction = [ini getInt:@"Direction" inSection:@"SoundPane" withDefault:DIR_LEFT_RIGHT];
	if([ini getInt:@"UseKnob" inSection:@"SoundPane" withDefault:0])
	{
		NSRect soundRc = [self rectFromIni:@"SoundPane"];
		//soundRc.size.width -= [[soundKnob image] size].width;
		//soundRc.size.height -= [[soundKnob image] size].height;
		
		
		if(direction == DIR_LEFT_RIGHT)
		{
			//soundRc.origin.y = 0;
			soundRc.origin.x += soundRc.size.width * ratio;
		}
		else if(direction == DIR_RIGHT_LEFT)
		{
			//soundRc.origin.y = 0;
			soundRc.origin.x += soundRc.size.width - soundRc.size.width * ratio;
		}
		else if(direction == DIR_BOTTOM_TOP)
		{
			soundRc.origin.y += soundRc.size.height * ratio;
			//soundRc.origin.x = 0;
		}
		else if(direction == DIR_TOP_BOTTOM)
		{
			soundRc.origin.y += soundRc.size.height - soundRc.size.height * ratio;
			//soundRc.origin.x = 0;
		}
		//soundRc.origin.x += 
		soundRc.size = [[soundKnob image] size];
		[self placeView:soundKnob fromRect:soundRc];
		//[soundKnob setFrame:soundRc];
	}
	else
	{
		// XXX
	}

}

-(void)drawProgressBar:(float)progressRatio
{
	int direction = [ini getInt:@"Direction" inSection:@"ProgressBar" withDefault:DIR_LEFT_RIGHT];
	// XXX knob stuff
	NSRect progressRc = [self rectFromIni:@"ProgressBar"];
	BOOL stretch = [ini getInt:@"StretchKnob" inSection:@"Knob" withDefault:0];
	if(stretch)
	{
		if(direction == DIR_LEFT_RIGHT)
		{
			float w = progressRc.size.width * progressRatio;
			float h = progressRc.size.height;
			progressRc = NSMakeRect(0,  0, w, h);
		}
		else if(direction == DIR_RIGHT_LEFT)
		{
			float w = progressRc.size.width * progressRatio;
			float h = progressRc.size.height;
			progressRc = NSMakeRect(progressRc.size.width - w,  0, w, h);
		}
		else if(direction == DIR_BOTTOM_TOP)
		{
			float w = progressRc.size.width;
			float h = progressRc.size.height * progressRatio;
			progressRc = NSMakeRect(0,  0, w, h);
		}
		else if(direction == DIR_TOP_BOTTOM)
		{
			float w = progressRc.size.width;
			float h = progressRc.size.height * progressRatio;
			progressRc = NSMakeRect(0,  progressRc.size.height - h, w, h);
		}
		
	}
	else
	{
		if(direction == DIR_LEFT_RIGHT)
		{
			progressRc.origin.y = 0;
			progressRc.origin.x = progressRc.size.width * progressRatio;
		}
		else if(direction == DIR_RIGHT_LEFT)
		{
			progressRc.origin.y = 0;
			progressRc.origin.x = progressRc.size.width - progressRc.size.width * progressRatio;
		}
		else if(direction == DIR_BOTTOM_TOP)
		{
			progressRc.origin.y = progressRc.size.height * progressRatio;
			progressRc.origin.x = 0;
		}
		else if(direction == DIR_TOP_BOTTOM)
		{
			progressRc.origin.y = progressRc.size.height - progressRc.size.height * progressRatio;
			progressRc.origin.x = 0;
		}
		progressRc.size = [[knob image] size];
	}
	
	if(stretch && ![ini getInt:@"useKnobBmp" inSection:@"Knob" withDefault:0] && ![ini getInt:@"UseBitmap" inSection:@"Knob" withDefault:0])
	{
		NSImage* img = [[[NSImage alloc] initWithSize:progressRc.size] autorelease];
		if(progressRc.size.width > 0 && progressRc.size.height > 0)
		{
			[img lockFocus];
			NSColor* inner = [self colorFromIni:@"InnerKnob"];
			NSColor* outer = [self colorFromIni:@"OuterKnob"];
			
			// create a rect in the center
			
			// create a oval bezier path using the rect
			NSRect oval = progressRc;
			NSBezierPath* path1 = [NSBezierPath bezierPathWithRect:oval];
			[path1 setLineWidth:1];	
			
			// draw the path
			[inner set];[path1 fill];	
			[outer set];[path1 stroke];
			
			[img unlockFocus];
		}
		[knob setImage:img];	
	}
	
	
	progressRc = NSRectToInts(progressRc);
	
	[self placeView:knob fromRect:progressRc];
	
}


-(void)update:(id)sender
{
	iTunesTrack* currentTrack = nil;
	NSString* notRunning =  @"iTunes is not running";
	NSString* name = notRunning;
	if([iTunes isRunning])
	{
		currentTrack = [iTunes currentTrack];
		name = [currentTrack name];
	}
	
	BOOL didChange = NO;
	NSString* songId = [iTunes isRunning] ? [NSString stringWithFormat:@"%d", [currentTrack databaseID]] : @"";
	if(![currentSongId isEqual:songId])
	{
		[currentSongId release];
		currentSongId = songId;
		[currentSongId retain];
		
		didChange = YES;
	}
	
	if(![iTunes isRunning] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hideWheniTunesIsClosed"])
	{

		if(self.window.alphaValue == 1)
			[self.window.animator setAlphaValue:0.0];
	}
	else
	{
		if(self.window.alphaValue == 0)
			[self.window.animator setAlphaValue:1.0];
	}

	
	if(![iTunes isRunning] && ![[label stringValue] isEqualToString: notRunning])
	{
		[label setStringValue:notRunning];
	}
	
	if(didChange)
	{
		if([iTunes isRunning])
			[label setStringValue:name ? name : @""];
		NSArray* artworks = [iTunes isRunning] ? [currentTrack artworks] : nil;
		if([artworks count] > 0)
		{
			iTunesArtwork* artwork = [artworks objectAtIndex:0];
			[album setImage:[artwork data]];
			[album.animator setAlphaValue:1.0];
		}
		else
		{
			[album.animator setAlphaValue:0.0];
			//[album setImage:nil];
		}

		
		int numExtraInfo = [ini getInt:@"Count" inSection:@"ExtraInfos" withDefault:0];
		for(int i = 0; i < numExtraInfo; ++i)
		{
			NSString* sectionName = [NSString stringWithFormat:@"ExtraInfo-%d", i+1];
			NSTextField* lbl = [extraInfoPanes objectAtIndex:i];
			NSString* type = [[ini getString:@"type" inSection:sectionName withDefault:@"name"] lowercaseString];
			
			NSString* value = @"";
			if([type isEqualToString:@"name"])
			{
				value = [iTunes isRunning] ? [currentTrack name] : @"";
			}
			else if([type isEqualToString:@"genre"])
			{
				value =[iTunes isRunning] ? [currentTrack genre] : @"";
			}
			else if([type isEqualToString:@"album"])
			{
				value = [iTunes isRunning] ? [currentTrack album] : @"";
			}
			else if([type isEqualToString:@"length"])
			{
				value = [iTunes isRunning] ? [currentTrack time] : @"";
			}
			else if([type isEqualToString:@"artist"])
			{
				value = [iTunes isRunning] ? [currentTrack artist] : @"";
			}
			
			[lbl setStringValue:value ? value : @""];
		}
	}
	
	int position = [iTunes isRunning] ? [iTunes playerPosition] : 0;
	int duration = [iTunes isRunning] ? [currentTrack duration] : 0;
	[counter setStringValue:[NSString stringWithFormat:@"%.2d:%.2d", position / 60, position %60]];
	
	float progressRatio = duration > 0 ? (float)position / (float)duration : 0.0f;
	[self drawProgressBar:progressRatio];
	
	// XXX take direction into account
	float rating = [iTunes isRunning] ? (float)[currentTrack rating]  / 100.0 : 0.0;
	NSRect ratingRc = [self rectFromIni:@"RatingPane"];
	ratingRc.size.width *= rating;
	[self placeView:ratingFilled fromRect:ratingRc];
	
	if(![iTunes isRunning] || [iTunes playerState] != iTunesEPlSPlaying)
	{
		if([pause alphaValue] != 1.0)
			[pause.animator setAlphaValue:1.0];
	}
	else
	{
		if([pause alphaValue] != 0.0)
			[pause.animator setAlphaValue:0.0];
	}
	
	if([iTunes isRunning])
	{
		int volume = [iTunes soundVolume];
		if(volume  != prevVolume)
		{
			[self updateSoundVolume: volume];
			prevVolume = volume;
		}
	}
	
	//[[self window] display];
	//[[self window] setHasShadow:NO];
	//[[self window] setHasShadow:YES];
}

-(void)updateImageView:(AveImageView*)imageView withImage:(NSString*)name
{
	NSString* imgPath = [path stringByAppendingPathComponent:@"Images"];
	imgPath = [imgPath stringByAppendingPathComponent:name];
	NSImage* img = [[NSImage alloc] initWithContentsOfFile:imgPath];
	[imageView setImage:img];
}

-(void)setLabel:(NSTextField*)textfield fromIni:(NSString*)sectionName
{
	NSString* faceName = [ini getString:@"FaceName" inSection:sectionName withDefault:@"Lucida Sans Unicode"];
	if([[faceName lowercaseString] isEqual:@"lucida sans unicode"])
		faceName = @"Lucida Grande";
	
	float size = [ini getFloat:@"Size" inSection:sectionName withDefault:12];
	int style = [ini getInt:@"Int" inSection:sectionName withDefault:1];
	int hAlignment = [ini getInt:@"HAlignment" inSection:sectionName withDefault:0];
	NSColor* color = [self colorFromIni:sectionName];	
	NSFont* font = [NSFont fontWithName:faceName size:size];
	//if(nil == font)
	//	font = [NSFont fontWithName:@"Lucida Grande" size:size];
	

	NSFontManager* manager = [NSFontManager sharedFontManager];
	if(style & 1) // bold
		font = [manager convertFont:font toHaveTrait:NSBoldFontMask];
	
	if(style & 2) // italic
		font = [manager convertFont:font toHaveTrait:NSItalicFontMask];
	
	//if(style & 4) // underline
	//	[textfield set
	
	//	if(style & 8) // strikeout
	//	font = [manager convertFont:font toHaveTrait:NSBoldFontMask];
	
	
	int doShadow = [ini getInt:@"Shadow" inSection:sectionName withDefault:0];
	float blurRatio = [ini getFloat:@"ShadowBlurRatio" inSection:sectionName withDefault:10] / 10.0;
	int xOffset = [ini getInt:@"ShadowXOffset" inSection:sectionName withDefault:1];
	int yOffset = [ini getInt:@"ShadowYOffset" inSection:sectionName withDefault:1];
	//int extraW = [ini getInt:@"ShadowExtraWidth" inSection:sectionName withDefault:1];
	//int extraH = [ini getInt:@"ShadowExtraHeight" inSection:sectionName withDefault:1];
	
	int sa = [ini getInt:@"ShadowColorA" inSection:sectionName withDefault:255];
	int sr = [ini getInt:@"ShadowColorR" inSection:sectionName withDefault:255];
	int sg = [ini getInt:@"ShadowColorG" inSection:sectionName withDefault:255];
	int sb = [ini getInt:@"ShadowColorB" inSection:sectionName withDefault:255];
	
	NSColor* shadowColor = [NSColor colorWithCalibratedRed:((float)sr)/255.0 green:(float)(sg)/255.0 blue:(float)(sb)/255.0 alpha:(float)(sa)/255.0];
	
	[textfield setTextColor:color];
	[textfield setFont:font];
	if(hAlignment == 2)
		[textfield setAlignment:NSRightTextAlignment];
	else if(hAlignment == 1)
		[textfield setAlignment:NSCenterTextAlignment];
	else
		[textfield setAlignment:NSLeftTextAlignment];
	
	
	NSShadow* shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:shadowColor];
	[shadow setShadowOffset:NSMakeSize(xOffset, -1 * yOffset)];
	[shadow setShadowBlurRadius:blurRatio];
	[textfield setShadow:doShadow ? shadow : nil];
}

-(void)selectNewSkin:(NSString*)skinPath
{
	[mouseOutSkin release];
	mouseOutSkin = nil;
	[self setSkin:skinPath];
}

-(void)setSkin:(NSString*)skinPath
{
	[currentSongId release];
	currentSongId = nil;
	prevVolume = -1;

	[path release];
	path = [AveTunes1AppDelegate pathForSkin:skinPath];
	[path retain];
	
	[skinName release];
	skinName = skinPath;
	[skinName retain];
	
	NSUserDefaults*  defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:skinPath forKey:@"skin"];
	[defaults setInteger:1 forKey:@"applyingSkin"];
	[defaults synchronize];
	
	ini = [IniFile iniFileWithContentsOfFile:[path stringByAppendingPathComponent:@"skin.ini"]];
	NSRect rc = [[self window] frame];
	rc.size.width = [ini getFloat:@"width" inSection:@"bg" withDefault:266];
	rc.size.height = [ini getFloat:@"height" inSection:@"bg" withDefault:108];
	//[[self window] setFrame:rc display:YES animate:NO];
	
	
	rc.origin.x = 0;
	rc.origin.y = 0;
	[bg setFrame:rc];
	[self.window.contentView setFrame: rc];
	[self updateImageView:bg withImage:@"bg.png"];

	
	[self placeView: box fromIni:@"DisplayPane"];
	
	[self placeView:label fromIni:@"InfoPane"];
	[self setLabel:label fromIni:@"InfoPane"];
	[self setLabel:label fromIni:@"Font"];
	
	[self placeView:counter fromIni:@"CounterPane"];
	[self setLabel:counter fromIni:@"CounterPane"];
	[self setLabel:counter fromIni:@"CounterFont"];
	
	[self updateImageView:ratingUnfilled withImage:@"rating_unfilled.png"];
	[self placeView:ratingUnfilled fromIni:@"RatingPane"];
	
	[self updateImageView:ratingFilled withImage:@"rating_filled.png"];
	[self placeView:ratingFilled fromIni:@"RatingPane"];
	
	
	[self placeView:progress fromIni:@"ProgressBar"];
	
	//[self placeView:sound fromIni:@"SoundPane"];
	
	[soundKnob setImage:nil];
	
	if([ini getInt:@"UseKnob" inSection:@"SoundPane" withDefault:0])
	{
		[self updateImageView:soundKnob withImage:@"sound_knob.png"];	
	}
	else
	{
		//
	}

	
	
	[self updateImageView:pause withImage:@"pause.png"];
	[self placeView:pause fromIni:@"PausePlayButton"];
	
	if([ini getInt:@"useKnobBmp" inSection:@"Knob" withDefault:0] || [ini getInt:@"UseBitmap" inSection:@"Knob" withDefault:0])
	{
		[self updateImageView:knob withImage:@"knob.png"];
	}
	else
	{
		// owner drawn the knob once
		float w = [ini getFloat:@"Width" inSection:@"Knob" withDefault:5];
		float h = [ini getFloat:@"Height" inSection:@"Knob" withDefault:5];
		BOOL stretch = [ini getInt:@"StretchKnob" inSection:@"Knob" withDefault:0];
		if(!stretch && w > 0 && h > 0)
		{
			NSImage* img = [[NSImage alloc] initWithSize:NSMakeSize(w,h)];
			
			[img lockFocus];
			NSColor* inner = [self colorFromIni:@"InnerKnob"];
			NSColor* outer = [self colorFromIni:@"OuterKnob"];
			
			// create a rect in the center
			
			// create a oval bezier path using the rect
			NSRect oval = NSMakeRect(0, 0, w, h);
			NSBezierPath* path1 = [NSBezierPath bezierPathWithOvalInRect:oval];
			[path1 setLineWidth:1];	
			
			// draw the path
			[inner set];[path1 fill];	
			[outer set];[path1 stroke];
			
			[img unlockFocus];
			[knob setImage:img];
		}
		else
		{
			[knob setImage:nil];
		}

	}

	
	if([ini getInt:@"Show" inSection:@"AlbumArt" withDefault:0])
	{
		[album setHidden:NO];
		[albumOverlay setHidden:NO];
		
		[self placeView:album fromIni:@"AlbumArt"];
		[self placeView:albumOverlay fromIni:@"AlbumArt"];
		
		if([ini getInt:@"DrawOverlay" inSection:@"AlbumArt" withDefault:0])
			[self updateImageView: albumOverlay withImage:@"overlay.png"];
		else
			[albumOverlay setImage:nil];
		
		if([ini getInt:@"DrawOverlayActualSize" inSection:@"AlbumArt" withDefault:0])
		{
			[albumOverlay setImageScaling:NSScaleNone];
			//[albumOverlay setImageAlignment:NSImageAlignTopLeft];
			NSSize size = [[albumOverlay image] size];
			NSRect rc = [self rectFromIni:@"AlbumArt"];
			rc.size = size;
			[self placeView:albumOverlay fromRect: rc];
		}
		else
		{
			[albumOverlay setImageScaling:NSScaleToFit];
			//[albumOverlay setImageAlignment:NSImageAlignTopLeft];
		}

	}
	else
	{
		[album setHidden:YES];
		[albumOverlay setHidden:YES];
	}

	
	
	for(NSView* view in extraInfoPanes)
		[view removeFromSuperview];
	[extraInfoPanes removeAllObjects];
	[extraInfoPanes release];
	extraInfoPanes = [[NSMutableArray alloc] init];
	int numExtraInfo = [ini getInt:@"Count" inSection:@"ExtraInfos" withDefault:0];
	for(int i = 0; i < numExtraInfo; ++i)
	{
		NSString* sectionName = [NSString stringWithFormat:@"ExtraInfo-%d", i+1];
		NSTextField* lbl = [[[NSTextField alloc] init] autorelease];
		[lbl setWantsLayer:YES];
		[lbl setBordered:NO];
		[lbl setSelectable:NO];
		[lbl setBackgroundColor:[NSColor redColor]];
		[lbl setDrawsBackground:NO];
		[box addSubview:lbl];
		[self placeView:lbl fromIni:sectionName];
		[self setLabel:lbl fromIni:sectionName];
		//[lbl setStringValue:sectionName];
		[extraInfoPanes addObject:lbl];
		
	}
	
	[self update:nil];
	
	rc = [[self window] frame];
	rc.size.width = [ini getFloat:@"width" inSection:@"bg" withDefault:266];
	rc.size.height = [ini getFloat:@"height" inSection:@"bg" withDefault:108];
	[[self window] setFrame:rc display:YES animate:NO];
	[[self window] setHasShadow:NO];
	
	[defaults setInteger:0 forKey:@"applyingSkin"];
	[defaults synchronize];
	
	/*
	NSRect trackingRect = NSMakeRect(0, 0, rc.size.width, rc.size.height);
	NSTrackingArea* tracking = [[[NSTrackingArea alloc] 
								initWithRect:trackingRect 
								options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways
								owner:[[NSApplication sharedApplication] delegate] 
								userInfo:nil] autorelease];
	[self.window.contentView addTrackingArea:tracking];
	*/
	//[bg addTrackingRect:trackingRect owner:self userData:NULL assumeInside:NO];
	
	//[self.window setFrame: self.window.frame display:YES animate:YES];
}

BOOL PointInRect(NSPoint p, NSRect rc)
{
	return	p.x >= rc.origin.x && 
			p.y >= rc.origin.y &&
			p.x <= rc.origin.x + rc.size.width && 
			p.y <= rc.origin.y + rc.size.height;
}


-(void)skinFromHotSpot:(NSString*)sectionName andIniFile:(IniFile*)iniFile isMouseOut:(BOOL)isMouseOut
{
	int count = [iniFile getInt:@"EasyAnimationFramesCount" inSection:sectionName withDefault:0];
	animCounter = 0;
	
	[animFrames release];
	animFrames = [[NSMutableArray alloc] init];
	for(int i = 0; i < count; ++i)
	{
		int index = !isMouseOut ? i + 1 : count - i;
		NSString* keyName = [NSString stringWithFormat:@"EasyAnimationFrame%d", index];
		NSString* img = [iniFile getString:keyName inSection:sectionName withDefault:@""];
		NSString* imgPath = [[iniFile path] stringByDeletingLastPathComponent];
		imgPath = [imgPath stringByAppendingPathComponent:@"Images"];
		imgPath = [imgPath stringByAppendingPathComponent:img];
		[animFrames insertObject:imgPath atIndex:[animFrames count]];
		
	}
	
	if(!isMouseOut)
	{
		[newSkin release];
		newSkin = [iniFile getString:@"NewSkinName" inSection:sectionName withDefault:@""];
		[newSkin retain];
	}
	else
	{
		[newSkin release];
		newSkin = mouseOutSkin;
		[newSkin retain];
	}

	
	
	if(count > 0)
	{
		[animationName release];
		animationName = sectionName;
		[animationName retain];
		
		if(![iniFile getInt:@"UseCurrentSkinSizeForAnimation=1" inSection:sectionName withDefault:0])
		{
			NSRect rc = [[self window] frame];
			rc.size.width = [iniFile getFloat:@"newbgwidth" inSection:sectionName withDefault:0];
			rc.size.height = [iniFile getFloat:@"newbgheight" inSection:sectionName withDefault:0];
			if(rc.size.width != 0 && rc.size.height != 0)
			{
				NSRect bgRc = rc;
				bgRc.origin.x = 0;
				bgRc.origin.y = 0;
				[self placeView:bg fromRect:bgRc];
				[[self window] setFrame:rc display:YES animate:NO];
				[[self window] setHasShadow:NO];
			}
		}
		
		
		//NoHideDuringAnimation=1
		//				AlbumArtShowDuringAnimation=0
		//				SoundShowDuringAnimation=1
		//				ProgressShowDuringAnimation=1
		//				RatingShowDuringAnimation=0
		//				CounterShowDuringAnimation=1
		//				InfoShowDuringAnimation=1
		//				DisplayShowDuringAnimation=1
		//				ShowExtraPanesDuringAnimationCount=0
		//				ShowExtraPanesDuringAnimation1=0
		//				ShowExtraPanesDuringAnimation2=0
		
		if(![iniFile getInt:@"NoHideDuringAnimation" inSection:sectionName withDefault:0])
		{
			[box setHidden:YES];
			[album setHidden:YES];
			[albumOverlay setHidden:YES];
			for(NSView* v in extraInfoPanes)
				[v setHidden:YES];
		}
		else
		{
			if(![iniFile getInt: @"AlbumArtShowDuringAnimation" inSection:sectionName withDefault:0])
			{
				[album setHidden:YES];
				[albumOverlay setHidden:YES];
			}
			
			if(![iniFile getInt: @"ProgressShowDuringAnimation" inSection:sectionName withDefault:0])
				[progress setHidden:YES];
			
			if(![iniFile getInt: @"RatingShowDuringAnimation" inSection:sectionName withDefault:0])
			{
				[ratingFilled setHidden:YES];
				[ratingUnfilled setHidden:YES];
			}
			
			if(![iniFile getInt: @"CounterShowDuringAnimation" inSection:sectionName withDefault:0])
				[counter setHidden:YES];
			
			if(![iniFile getInt: @"InfoShowDuringAnimation" inSection:sectionName withDefault:0])
				[label setHidden:YES];
			
			if(![iniFile getInt: @"DisplayShowDuringAnimation" inSection:sectionName withDefault:0])
				[box setHidden:YES];
			
			int c = [iniFile getInt:@"ShowExtraPanesDuringAnimationCount" inSection:sectionName withDefault:0];
			for(int x = 0; x < c; ++x)
			{
				NSString* keyName = [NSString stringWithFormat:@"ShowExtraPanesDuringAnimations%d", c+1];
				if(![iniFile getInt: keyName inSection:sectionName withDefault:0] && c < [extraInfoPanes count])
					[(NSView*)[extraInfoPanes objectAtIndex:c] setHidden:YES];
			}
		}
		
		
		[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(onAnimation:) userInfo:nil repeats:NO];
	}
	else
	{
		[self setSkin:newSkin];
	}
	
}

- (BOOL)mouseAction:(NSEvent *)theEvent
{  
	
	NSPoint location = [theEvent locationInWindow];
	location.y = [self.window frame].size.height - location.y;
	
	if(PointInRect(location, [self rectFromIni:@"NextButton"]))
	{
		[iTunes nextTrack];
		[self update:nil];
		return YES;
	}
	else if(PointInRect(location, [self rectFromIni:@"PreviousButton"]))
	{
		[iTunes previousTrack];
		[self update:nil];
		return YES;
	}
	else if(PointInRect(location, [self rectFromIni:@"PreviousButton"]))
	{
		[iTunes previousTrack];
		[self update:nil];
		return YES;
	}
	else if(PointInRect(location, [self rectFromIni:@"PausePlayButton"]))
	{
		[iTunes playpause];
		[self update:nil];
		return YES;
	}
	else if(PointInRect(location, [self rectFromIni:@"MuteButton"]))
	{
		[iTunes mute];
		[self update:nil];
		return YES;
	}
	else if(PointInRect(location, [self rectFromIni:@"OpenButton"]))
	{
		[iTunes openLocation:@""];
		[self update:nil];
		return YES;
	}
	else if(PointInRect(location, [self rectFromIni:@"ToggleITunesWindowButton"]))
	{
		[[iTunes windows] performSelector:@selector(hide)];
		[self update:nil];
		return YES;
	}
	else if(PointInRect(location, [self rectFromIni:@"QuitButton"]))
	{
		[iTunes quit];
		[self update:nil];
		return YES;
	}
	else
	{
		NSRect display = [self rectFromIni:@"DisplayPane"];
		NSPoint p = location;
		p.x -= display.origin.x;
		p.y -= display.origin.y;
		if(PointInRect(p, [self rectFromIni:@"ProgressBar"]))
		{
			NSRect progressBar = [self rectFromIni:@"ProgressBar"];
			
			iTunesTrack* currentTrack = [iTunes currentTrack];
			int duration = [currentTrack duration];
			// XXX direction
			p.x -= progressBar.origin.x;
			float ratio = progressBar.size.width > 0 ? (float)p.x / (float)progressBar.size.width : 0.0;
			[iTunes setPlayerPosition:ratio * duration];
			[self update:nil];
			return YES;
		}
		if(PointInRect(p, [self rectFromIni:@"SoundPane"]))
		{
			NSRect soundPane = [self rectFromIni:@"SoundPane"];
			
			// XXX direction
			p.x -= soundPane.origin.x;
			float ratio = soundPane.size.width > 0 ? (float)p.x / (float)soundPane.size.width : 0.0;
			[iTunes setSoundVolume:(int)(100.0 * ratio)];
			[self update:nil];
			return YES;
		}
		else if(PointInRect(p, [self rectFromIni:@"RatingPane"]))
		{
			NSRect progressBar = [self rectFromIni:@"RatingPane"];
			
			iTunesTrack* currentTrack = [iTunes currentTrack];
			// XXX direction
			p.x -= progressBar.origin.x;
			float ratio = progressBar.size.width > 0 ? (float)p.x / (float)progressBar.size.width : 0.0;
			ratio = (int)(ratio * 5 + 0.5);
			[currentTrack setRating:ratio * 20];
			[self update:nil];
			return YES;
		}
		
		//sEyeTunes* eyetunes = [EyeTunes sharedInstance];
		//[eyetunes set];
	}
	
	int numExtraInfo = [ini getInt:@"Count" inSection:@"ChangeSkinHotSpots" withDefault:0];
	for(int i = 0; i < numExtraInfo; ++i)
	{
		NSString* sectionName = [NSString stringWithFormat:@"ChangeSkinHotSpot-%d", i+1];
		NSRect rc = [self rectFromIni:sectionName];
		if(![[ini getString:@"type" inSection:sectionName withDefault:@"click"] isEqual:@"click"])
			continue;
		
		
		if(PointInRect(location, rc))
		{
			if(![[NSUserDefaults standardUserDefaults] boolForKey:@"noSkinSounds"])
			{
				NSString* soundName = [ini getString:@"SoundForAnimation" inSection:sectionName withDefault:nil];
				if(soundName != nil)
				{
					NSString* soundPath = [path stringByAppendingPathComponent:soundName];
					NSSound *sound = [[NSSound alloc] initWithContentsOfFile:soundPath byReference: YES];
					[sound play];
					
				}
			}
			[self skinFromHotSpot:sectionName andIniFile:ini isMouseOut:NO];
			return YES;
		}
		
	}
	
	return NO;
}

-(void)mouseUp:(NSEvent *)theEvent
{
	[self mouseAction:theEvent];
}



-(void)onAnimation:(id)sender
{
	if(animCounter < [animFrames count])
		[bg setImage:[[[NSImage alloc] initWithContentsOfFile:[animFrames objectAtIndex:animCounter]] autorelease]];
	
	animCounter++;
	if(animCounter <  [animFrames count])
	{
		[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(onAnimation:) userInfo:nil repeats:NO];	
	}
	else
	{
		BOOL fadeAlbum = [ini getInt:@"fadeAlbumArtIn" inSection:animationName withDefault:0];
		if(fadeAlbum)
			[album setAlphaValue:0];
		[self setSkin:newSkin];
		if(fadeAlbum)
		{
			//[album.animator stopAnimation];
			//[album setAlphaValue:0];
			//[album.animator setAlphaValue:1];
		}
		
		[label setHidden:NO];
		[progress setHidden:NO];
		[ratingFilled setHidden:NO];
		[ratingUnfilled setHidden:NO];
		[counter setHidden:NO];
		[box setHidden:NO];
		[album setHidden:![ini getInt:@"Show" inSection:@"AlbumArt" withDefault:0]];
		[albumOverlay setHidden:![ini getInt:@"Show" inSection:@"AlbumArt" withDefault:0]];
		for(NSView* v in extraInfoPanes)
			[v setHidden:NO];
		
		//[self updateImageView:bg withImage:@"bg.png"];
	}

}


-(void)mouseExited:(NSEvent *)theEvent
{
	if(mouseOutSkin && [mouseOutSkin length] > 0)
	{
		[self skinFromHotSpot:mouseOutSection andIniFile:mouseOutIni isMouseOut:YES];
		//[self setSkin:mouseOutSkin];
		[mouseOutSkin release];
		mouseOutSkin = nil;
	}
}

-(void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	location.y = [self.window frame].size.height - location.y;
	
	int numExtraInfo = [ini getInt:@"Count" inSection:@"ChangeSkinHotSpots" withDefault:0];
	for(int i = 0; i < numExtraInfo; ++i)
	{
		NSString* sectionName = [NSString stringWithFormat:@"ChangeSkinHotSpot-%d", i+1];
		NSRect rc = [self rectFromIni:sectionName];
		if(![[ini getString:@"type" inSection:sectionName withDefault:@"click"] isEqual:@"hover"])
			continue;
		if(PointInRect(location, rc))
		{
			mouseOutRect = rc;
			[mouseOutSkin release];
			mouseOutSkin = [ini getString:@"mouseoutskinname" inSection:sectionName withDefault:@""];
			[mouseOutSkin retain];
			[mouseOutIni release];
			mouseOutIni = ini;
			[mouseOutIni retain];
			[mouseOutSection release];
			mouseOutSection = sectionName;
			[mouseOutSection retain];
			[self skinFromHotSpot:sectionName andIniFile:ini isMouseOut:NO];
			return;
		}
	}
	
	if(mouseOutSkin && [mouseOutSkin length] > 0 && !PointInRect(location, mouseOutRect))
	{
		[self skinFromHotSpot:mouseOutSection andIniFile:mouseOutIni isMouseOut:YES];
		//[self setSkin:mouseOutSkin];
		[mouseOutSkin release];
		mouseOutSkin = nil;
	}
}

+ (void)popUpMenu:(NSMenu *)menu forView:(NSView *)view pullsDown:(BOOL)pullsDown {
    NSRect frame = [view frame];
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
	
    if (pullsDown) [menu insertItemWithTitle:@"" action:NULL keyEquivalent:@"" atIndex:0];
	
    NSPopUpButtonCell *popUpButtonCell = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:pullsDown];
    [popUpButtonCell setMenu:menu];
    if (!pullsDown) [popUpButtonCell selectItem:nil];
    [popUpButtonCell performClickWithFrame:frame inView:view];
}



-(NSMenu*)menuWithSkins
{
	NSMenu* menu = [[[NSMenu alloc] init] autorelease];
	
	for(NSString* skin in [AveTunes1AppDelegate skins])
	{
		NSMenuItem* item = [menu insertItemWithTitle:skin action:@selector(onSkinMenuItem:) keyEquivalent:@"" atIndex:0];
		[item setTarget:self];
	}
	
	return menu;
}


-(void)onSkinMenuItem:(NSMenuItem*)item
{
	[self setSkin:[item title]];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}


-(void)rightMouseUp:(NSEvent *)theEvent
{
	[self mouseExited:theEvent];
	NSMenu* menu = [self menuWithSkins];
	[MainWindowController popUpMenu:menu forView:self.window.contentView pullsDown:NO];
	
	
}

-(void)setWindowLevel:(int)level
{
	switch(level)
	{
		default:
		case 0: [[self window] setLevel:kCGDesktopWindowLevel + 1]; break;
		case 1: [[self window] setLevel:kCGNormalWindowLevel]; break;
		case 2: [[self window] setLevel:kCGFloatingWindowLevel]; break;
	}	
}

//observeValueForKeyPath:ofObject:change:context
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"windowLevel"]) {
		int level = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
		[self setWindowLevel:level];
    }
    // be sure to call the super implementation
    // if the superclass implements it
   /* [super observeValueForKeyPath:keyPath
						 ofObject:object
						   change:change
						  context:context];*/
}


- (void)awakeFromNib
{
	iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	if(![iTunes isRunning] && [[NSUserDefaults standardUserDefaults] boolForKey:@"launchiTunes"])
		[iTunes run];
	
	[[self window] setAcceptsMouseMovedEvents:YES];

	[self setWindowLevel:[[NSUserDefaults standardUserDefaults] integerForKey:@"windowLevel"]];
	
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"windowLevel" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
	
	[self.window setAlphaValue:0];
	[self.window.animator setAlphaValue:1.0];
	
	
	NSRect zero = {0};
	bg = [[AveImageView alloc] initWithFrame:zero];
	ratingFilled = [[AveImageView alloc] initWithFrame:zero];
	ratingUnfilled = [[AveImageView alloc] initWithFrame:zero];
	album = [[AveImageView alloc] initWithFrame:zero];
	albumOverlay = [[AveImageView alloc] initWithFrame:zero];
	knob = [[AveImageView alloc] initWithFrame:zero];
	pause = [[AveImageView alloc] initWithFrame:zero];
	dragBg = [[AveImageView alloc] initWithFrame:zero];
	
	box = [[AveImageView alloc] initWithFrame:zero];
	progress = [[AveImageView alloc] initWithFrame:zero];
	//sound = [[AveImageView alloc] initWithFrame:zero];
	//[sound setBackgroundColor:[NSColor redColor]];
	soundKnob = [[AveImageView alloc] initWithFrame:zero];
	
	[dragBg setBackgroundColor:[NSColor selectedMenuItemColor]];
	
	[box addSubview:progress];
	[box addSubview:soundKnob];
	
	//[sound addSubview:soundKnob];
	
	label = [[[NSTextField alloc] init] autorelease];
	[label setWantsLayer:YES];
	[label setBordered:NO];
	[label setSelectable:NO];
	[label setBackgroundColor:[NSColor redColor]];
	[label setDrawsBackground:NO];
	[box addSubview:label];
		
	counter = [[[NSTextField alloc] init] autorelease];
	[counter setWantsLayer:YES];
	[counter setBordered:NO];
	[counter setSelectable:NO];
	[counter setBackgroundColor:[NSColor redColor]];
	[counter setDrawsBackground:NO];
	[box addSubview:counter];
	
	NSWindow* window = self.window;
	[window.contentView addSubview:dragBg];
	[window.contentView addSubview:bg];
	[window.contentView addSubview:pause];
	[window.contentView addSubview:album];
	[window.contentView addSubview:albumOverlay];
	[window.contentView addSubview:box];
	
	[box addSubview:ratingUnfilled];
	[box addSubview:ratingFilled];
	[progress addSubview:knob];
	
	
	[self.window setAcceptsMouseMovedEvents:YES];
	[bg setAutoresizingMask:0];
	[box setAutoresizingMask:0];
	[album setAutoresizingMask:0];
	[albumOverlay setAutoresizingMask:0];
	[pause setAutoresizingMask:0];
	
	//[bg setImageAlignment:NSImageAlignTopLeft];
	
	[ratingFilled setImageScaling:NSScaleNone];
	//[ratingFilled setImageAlignment:NSImageAlignTopLeft];
	
	[ratingUnfilled setImageScaling:NSScaleNone];
	//[ratingUnfilled setImageAlignment:NSImageAlignTopLeft];
	
	[knob setImageScaling:NSScaleNone];
	//[knob setImageAlignment:NSImageAlignTopLeft];
	
	[album setImageScaling:NSScaleToFit];
	//[album setImageAlignment:NSImageAlignTopLeft];
	
	[albumOverlay setImageScaling:NSScaleToFit];
	//[albumOverlay setImageAlignment:NSImageAlignTopLeft];
	
	[pause setImageScaling:NSScaleToFit];
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	if([defaults objectForKey:@"framex"] != nil)
	{
		NSRect rc = [window frame];
		rc.origin.x = [defaults integerForKey:@"framex"];
		rc.origin.y = [defaults integerForKey:@"framey"];
		[window setFrameOrigin:rc.origin];
	}
	
	NSString* skin = [defaults stringForKey:@"skin"];
	if(!skin || [defaults integerForKey:@"applyingSkin"])
		skin = @"Hibrido iTunes Remote";
	[self setSkin:skin];
	[self update:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}




@end
