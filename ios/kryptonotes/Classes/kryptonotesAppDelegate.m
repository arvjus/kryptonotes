//
//  kryptonotesAppDelegate.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "kryptonotesAppDelegate.h"
#import "DocSelectViewcontroller.h"
#import "MainViewController.h"
#import "Document.h"

@implementation kryptonotesAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    NSArray *availableDocuments = [DocSelectViewController listAvailableDocuments];
    if ([availableDocuments count] > 1) {
        DocSelectViewController *controller = [[DocSelectViewController alloc] initWithNibName:@"DocSelectView" andAvailableDocuments:availableDocuments];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        NSString *docname = nil;
        if ([availableDocuments count] == 1) {
            docname = [availableDocuments objectAtIndex:0];
        }
        [Document setFilename:docname];
        MainViewController *controller = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    }

    // Add the navigation controller's view to the window and display.
    self.navigationController.navigationBar.translucent = NO;
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

