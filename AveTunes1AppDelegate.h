//
//  AveTunes1AppDelegate.h
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AveTunes1AppDelegate : NSObject{// <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

+(NSArray*)skins;
+(NSString*)pathForSkin:(NSString*)skinPath;

@end
