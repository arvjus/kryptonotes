//
//  DocumentParser.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DocumentParser.h"
#import "Item.h" 

@implementation DocumentParser

@synthesize documentParserDelegate;

- (id)initWithData:(NSData *)data
{
	if ((self = [super initWithData:data])) {
		[super setDelegate:self];
	}
	return self;
}

-  (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"items"]) {
		[self.documentParserDelegate didStartParsing];
	} else if ([elementName isEqualToString:@"item"]) {
		item = [[Item alloc] init];
		item.category = [attributeDict objectForKey:@"category"];
		item.title = [attributeDict objectForKey:@"title"];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"items"]) {
		[self.documentParserDelegate didEndParsing];
	} else if ([elementName isEqualToString:@"item"]) {
		item.content = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		currentElementValue = nil;
		
		[self.documentParserDelegate addItem:item];
		item = nil;
	}
}

@end
