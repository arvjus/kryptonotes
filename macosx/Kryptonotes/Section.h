//
//  Section.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Section : NSObject {
	NSString *name;
	NSMutableArray *items;
}

@property (strong) NSString *name;
@property (strong) NSMutableArray *items;

- (Boolean)isEqual:(id)object;

@end
