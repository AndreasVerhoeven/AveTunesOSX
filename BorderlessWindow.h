//
//  BorderlessWindow.h
//  AveTunes1
//
//  Created by Andreas Verhoeven on 12/16/09.
//  Copyright 2009 AveApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BorderlessWindow : NSWindow {
    // This point is used in dragging to mark the initial click location
    NSPoint initialLocation;
	BOOL inMove;
}

@property (assign) NSPoint initialLocation;

@end
