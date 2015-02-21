//
//  IniFile.m
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import "IniFile.h"

@interface CaseInsensitiveString : NSString {
    NSString *realString;
}
@end

@implementation CaseInsensitiveString

- (id)initWithString:(NSString *)aString {
    if((self = [self init]))
        realString = [aString copy];
    return self;
}

- (void)dealloc {
    [realString release];
    [super dealloc];
}

- (NSUInteger)length {
    return [realString length];
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [realString characterAtIndex:index];
}

- (BOOL)isEqualToString:(NSString *)aString {
    return [[realString lowercaseString] isEqualToString:[aString
														  lowercaseString]];
}

- (NSUInteger)hash {
    return [[realString lowercaseString] hash];
}

@end

@interface IniKeyString : NSObject <NSCopying>
{
	NSString* string;
}

-(NSString*)string;
-(id)initWithString:(NSString*)str;
+(id)keyWithString:(NSString*)str;
-(NSUInteger)hash;
-(BOOL)isEqual:(id)object;
- (id)copyWithZone:(NSZone *)zone;
  
@end

@implementation IniKeyString

- (id)copyWithZone:(NSZone *)zone
{
	IniKeyString* key = [[IniKeyString alloc] init];
	key->string = [self->string copyWithZone:zone];
	return key;
}

-(NSString*)string
{
	return string;
}

-(NSString*)description
{
	return string;
}

-(id)initWithString:(NSString*)str
{
	if(self = [super init])
	{
		string = str;
		[string retain];
	}
	
	return self;
	
}

+(id)keyWithString:(NSString*)str
{
	IniKeyString* key = [[IniKeyString alloc] init];
	if(key)
	{
		key->string = str;
		[key->string retain];
	}
	
	return key;
}

-(void)dealloc
{
	[string release];
	[super dealloc];
}

-(NSUInteger)hash
{
	return [[string lowercaseString] hash];
}

-(BOOL)isEqual:(id)object
{
	if([object class] == [self class])
	{
		NSString* thatString = [(IniKeyString*)object string];
		return [[string lowercaseString] isEqual:[thatString lowercaseString]];
	}
	else
	{
		return [[string lowercaseString] isEqual:object];
	}
}

@end

@implementation IniFile

@synthesize sections;

-(void)parseFromFile:(NSString*)path
{
	NSFileManager* manager = [NSFileManager defaultManager];
	if(![manager fileExistsAtPath:path])
		NSLog(@" %@ does not exist", path);
	
	NSError* error  = nil;
	NSString* data = [NSString stringWithContentsOfFile:path usedEncoding:nil error:&error];
	if(nil == data)
		data = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
	
	if(nil == data)
	{
		NSLog(@"error reading ini file: %@", [error description]);
		return;
	}
	
	NSString* currentSectionName = nil;
	
	NSArray* lines = [data componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
	for(NSString* line in lines)
	{
		line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if([line length] == 0) // ignore blank links
			continue;
		
		unichar first = [line characterAtIndex:0];
		if(first == L'[') // section start
		{
			// find section end
			NSRange sectionEndRange = [line rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"]"]];
			if(sectionEndRange.location == NSNotFound)
			{
				continue; // no valid section name, skip
			}
			
			NSRange range;
			range.length = sectionEndRange.location-1;
			range.location = 1;
			NSString* sectionName = [line substringWithRange:range];
			sectionName = [sectionName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if(sectionName != nil && [sectionName length] > 0)
			{
				currentSectionName = sectionName;
			}
		}
		else
		{
			// search for comments and strip them off
			// comments start with a semicolon and run to the end of the line
			NSRange semicolonRange = [line rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
			if(semicolonRange.location != NSNotFound)
			{
				line = [line substringToIndex:semicolonRange.location];
			}
			
			NSRange seperatorRange = [line rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"=:"]];
			if(seperatorRange.location == NSNotFound) // no seperator found, weird line it seems, just continue
				continue;
			
			NSString* key = [line substringToIndex:seperatorRange.location];
			NSString* value = [line substringFromIndex:seperatorRange.location+seperatorRange.length];
			
			key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			if(!currentSectionName)
			{
				currentSectionName = @"";
			}
			
			if([self getString:key inSection:currentSectionName withDefault:nil] == nil)
				[self setValue:value forKey:key inSection:currentSectionName];
		}

	}
}
				 
-(void)setValue:(NSString*)value forKey:(NSString*)key inSection:(NSString*)sectionName
{
	IniKeyString* iniSection = [[IniKeyString alloc] initWithString:sectionName];
	NSMutableDictionary* section = [sections objectForKey:iniSection];
	if(nil == section)
	{
		section = [NSMutableDictionary dictionary];
		[sections setObject:section forKey:iniSection];
	}
	
	IniKeyString* iniKey = [[IniKeyString alloc] initWithString:key];
	[section setObject:value forKey:iniKey];
}


-(NSString*)getString:(NSString*)key inSection:(NSString*)sectionName withDefault:(NSString*)defaultValue
{
	IniKeyString* iniSection = [[IniKeyString alloc] initWithString:sectionName];
	NSMutableDictionary* section = [sections objectForKey:iniSection];
	if(nil == section)
		return defaultValue;
	
	IniKeyString* iniKey = [[IniKeyString alloc] initWithString:key];
	NSString* value = [section objectForKey:iniKey];
	return value != nil ? value : defaultValue;
}

-(int)getInt:(NSString*)key inSection:(NSString*)sectionName withDefault:(int)defaultValue
{
	NSString* str = [self getString:key inSection:sectionName withDefault:nil];
	return str != nil ? [str integerValue] : defaultValue;
}

-(float)getFloat:(NSString*)key inSection:(NSString*)sectionName withDefault:(float)defaultValue
{
	NSString* str = [self getString:key inSection:sectionName withDefault:nil];
	return str != nil ? [str floatValue] : defaultValue;
}

+(IniFile*)iniFileWithContentsOfFile:(NSString*)path
{
	IniFile* ini = [IniFile alloc];
	return [ini initWithContentsOfFile:path];
}

+(IniFile*)iniFile
{
	IniFile* ini = [IniFile alloc];
	return [ini init];
}

-(IniFile*)initWithContentsOfFile:(NSString*)_path
{
	if(self = [self init])
	{
		[self parseFromFile:_path];
		path = _path;
		[path retain];
	}
	return self;
}

-(IniFile*)init
{
	if(self = [super init])
	{
		sections = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

-(NSString*)path
{
	return path;
}

-(void)dealloc
{
	[path release];
	[sections release];
	[super dealloc];
}

@end
