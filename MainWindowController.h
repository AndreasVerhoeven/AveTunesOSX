//
//  MainWindowController.h
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IniFile;
@class AveImageView;
@class iTunesApplication;

@interface MainWindowController : NSWindowController {
	NSTextField* label;
	
	NSView* box;
	NSTextField* counter;
	
	AveImageView* bg;
	AveImageView* ratingUnfilled;
	AveImageView* ratingFilled;
	AveImageView* album;
	AveImageView* albumOverlay;
	AveImageView* pause;
	AveImageView* dragBg;
	
	iTunesApplication *iTunes;
	
	
	NSView* progress;
	AveImageView* knob;
	
	//NSView* sound;
	AveImageView* soundKnob;
	
	int animCounter;
	NSMutableArray* animFrames;
	
	NSRect mouseOutRect;
	NSString* mouseOutSkin;
	NSString* animationName;
	NSString* newSkin;
	
	NSString* mouseOutSection;
	IniFile* mouseOutIni;
	
	NSString* skinName;
	NSString* path;
	IniFile* ini;
	
	NSMutableArray* extraInfoPanes;
	
	NSString* currentSongId;
	int prevVolume;
	
	
}

-(void)selectNewSkin:(NSString*)skinPath;
-(void)setSkin:(NSString*)skinPath;

@property (assign) int windowLevel;

@end
