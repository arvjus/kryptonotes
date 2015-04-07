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

@interface DocumentModel : NSObject <DocumentParserDelegate>

@property (nonatomic, assign) Boolean encrypted;
@property (nonatomic, assign) Boolean locked;
@property (nonatomic, assign) Boolean dirty;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *updated;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) NSInteger dataOffset;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSMutableArray *tmpSections;
@property (nonatomic, strong) NSMutableArray *masterSections;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSString *filter;


- (Boolean)setData:(NSData *)documentData andName:(NSString *)documentName error:( NSError **)outError;

- (Boolean)lockWithError:( NSError **)outError;
- (Boolean)unlockWithError:( NSError **)outError;

- (NSInteger)numberOfItems;
- (Item *)itemAtPos:(NSInteger)pos;
- (void)setItem:(Item *)item atPos:(NSInteger)pos markAsGroup:(Boolean)isGroup;
- (void)removeItemAtPos:(NSInteger)pos;
- (void)updateFilter:(NSString *)filter;

@end
