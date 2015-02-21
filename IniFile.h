//
//  IniFile.h
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IniFile : NSObject {
	NSMutableDictionary* sections;
	NSString* path;
}

@property (readonly) NSMutableDictionary* sections;

+(IniFile*)iniFileWithContentsOfFile:(NSString*)path;
+(IniFile*)iniFile;
-(IniFile*)initWithContentsOfFile:(NSString*)path;
-(IniFile*)init;
-(NSString*)path;

-(void)setValue:(NSString*)value forKey:(NSString*)key inSection:(NSString*)section;
-(NSString*)getString:(NSString*)key inSection:(NSString*)sectionName withDefault:(NSString*)defaultValue;
-(int)getInt:(NSString*)key inSection:(NSString*)sectionName withDefault:(int)defaultValue;
-(float)getFloat:(NSString*)key inSection:(NSString*)sectionName withDefault:(float)defaultValue;

-(void)dealloc;

@end
