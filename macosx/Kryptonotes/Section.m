//
//  Section.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Section.h"


@implementation Section

@synthesize name, items;

- (Boolean)isEqual:(id)object
{
	Boolean ret = NO;
	if ([object isKindOfClass:[Section class]]) {
		ret = [self.name isEqual:((Section *)object).name];
	}
	return ret;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"name: %@, items: %@", name, items];
}

@end
