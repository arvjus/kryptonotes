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
	id<DocumentParserDelegate> documentParserDelegate;

	Item *item;
	NSMutableString *currentElementValue;
}

@property (retain) id<DocumentParserDelegate> documentParserDelegate;

@end
