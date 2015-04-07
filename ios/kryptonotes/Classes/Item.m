//
//  Item.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize category, title, content;

- (NSString *)description {
	return [NSString stringWithFormat:@"category: %@, title: %@, content: %@", category, title, content];
}

- (void)dealloc {
	[category release];
	[title release];
	[content release];
	[super dealloc];
}

@end
