//
//  AveTunes1AppDelegate.m
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import "AveTunes1AppDelegate.h"

@implementation AveTunes1AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	NSUserDefaults*  defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[window frame].origin.x forKey:@"framex"];
	[defaults setInteger:[window frame].origin.y forKey:@"framey"];
	[defaults synchronize];	
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
	//NSMenu* menu = [[NSMenu alloc] init];
	//NSMenuItem* item = [menu addItemWithTitle:@"test" action:@selector(onItem:) keyEquivalent:@""];
	//[item setTarget: self];
    //return menu;
	return nil;
}

+(void)appendSkins:(NSMutableArray*)skins forDir:(NSString*)folder
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for(NSString* dir in [fileManager contentsOfDirectoryAtPath:folder error:nil])
	{
		if([dir characterAtIndex:0] == L'.')
			continue;
		
		NSString* skinIni = [folder stringByAppendingPathComponent:dir];
		skinIni = [skinIni stringByAppendingPathComponent:@"skin.ini"];
		if(![fileManager fileExistsAtPath:skinIni])
			continue;
		
		[skins addObject:dir];
	}
}

+(NSArray*)skins
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	
	NSString *folder = @"~/Library/Application Support/AveTunes/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO)
	{
		[fileManager createDirectoryAtPath: folder withIntermediateDirectories:YES attributes: nil error:nil];
	}
	
	
	NSMutableArray* skins = [NSMutableArray array];
	[AveTunes1AppDelegate appendSkins:skins forDir:folder];
	[AveTunes1AppDelegate appendSkins:skins forDir:[[NSBundle mainBundle] resourcePath]];
	
	
	return skins;
}

+(NSString*)pathForSkin:(NSString*)skinPath
{
	
	skinPath = [skinPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString* configPath = @"~/Library/Application Support/AveTunes/";
	configPath = [configPath stringByExpandingTildeInPath];
	configPath = [configPath stringByAppendingPathComponent:skinPath];
	
	if(![fileManager fileExistsAtPath:[configPath stringByAppendingPathComponent:@"skin.ini"]])
	{
		// check bundle
		configPath = [[NSBundle mainBundle] resourcePath];
		configPath = [configPath stringByAppendingPathComponent:skinPath];
	}
	
	return configPath;
}

// Handle a file dropped on the dock icon
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)path
{
	BOOL valid = NO;
	BOOL isDir = YES;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir)
	{
		NSString* name = [[path pathComponents] lastObject];
		NSString *dest = @"~/Library/Application Support/AveTunes/";
		dest = [dest stringByExpandingTildeInPath];
		dest = [dest stringByAppendingPathComponent:name];
		//if(sourceDragMask & NSDragOperationMove != 0)
		[fileManager moveItemAtPath:path toPath:dest error:nil];
		//else 
		//	[fileManager copyItemAtPath:file toPath:dest error:nil];
		
		valid = YES;
		
		[[[self window ] delegate]setSkin:name];
	}
	
	return NO;
}

@end
