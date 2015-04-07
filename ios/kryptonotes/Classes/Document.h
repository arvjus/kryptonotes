//
//  DocumentMgr.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentParser.h"

@class Item;

@interface Document : NSObject <DocumentParserDelegate> {
	NSData *data;
	NSString *name;
	NSString *algorithm;
	NSString *updated;
	Boolean encrypted;
	Boolean locked;
	
	NSMutableArray *sections;
}

@property (retain) NSData *data;
@property (retain) NSString *name;
@property (retain) NSString *algorithm;
@property (retain) NSString *updated;
@property (assign) Boolean encrypted;
@property (assign) Boolean locked;

@property (nonatomic, retain) NSMutableArray *sections;

+ (void)setFilename:(NSString *)filename;
+ (Document *)instance;
- (Boolean)lock;
- (Boolean)unlockWithPassword:(NSString *)passwd;

@end
