//
//  CDOAppDelegate.m
//  ObjCRubyMotionIntegration
//
//  Created by Jack Chen on 19/05/13.
//  Copyright (c) 2013 chendo. All rights reserved.
//

#import "CDOAppDelegate.h"
#import "CDORubyland.h"

@implementation CDOAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CDORubyland *ruby = [[CDORubyland alloc] init];
    [ruby countdown];
}

@end
