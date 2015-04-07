//
//  DocumentParser.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@protocol DocumentParserDelegate

- (void)didStartParsing;
- (void)didEndParsing;
- (void)addItem:(Item *)item;

@end


@interface DocumentParser : NSXMLParser<NSXMLParserDelegate> {
	Item *item;
	NSMutableString *currentElementValue;
}

@property (nonatomic, strong) id<DocumentParserDelegate> documentParserDelegate;

@end
