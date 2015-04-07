//
//  KNApplicationDelegate.m
//  Kryptonotes
//
//  Created by Arvid Juskaitis on 10/18/12.
//  Copyright (c) 2012 Arvid Juskaitis. All rights reserved.
//

#import "KNApplicationDelegate.h"

@implementation KNApplicationDelegate

// Delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSLog(@"Started app");
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

@end
