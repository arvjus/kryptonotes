//
//  Item.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize category, title, content, isGroup, itemIndex;

- (NSString *)description {
	return [NSString stringWithFormat:@"category: %@, title: %@, content: %@, isGroup: %d, itemIndex: %d", category, title, content, isGroup, itemIndex];
}

@end
