//
//  Item.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Item : NSObject

@property (strong) NSString *category;
@property (strong) NSString *title;
@property (strong) NSString *content;
@property (assign) Boolean isGroup;
@property (assign) NSInteger itemIndex;


@end
