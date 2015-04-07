//
//  Item.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Item : NSObject {
	NSString *category;
	NSString *title;
	NSString *content;
}

@property (retain) NSString *category;
@property (retain) NSString *title;
@property (retain) NSString *content;

@end
