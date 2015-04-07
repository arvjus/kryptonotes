//
//  DocumentMgr.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Document.h"
#import "crypt.h"
#import "Item.h"
#import "DocumentParser.h"
#import "Section.h"


@implementation Document

@synthesize data, name, algorithm, updated, encrypted, locked, sections;

static NSString *filename;
static Document *instance;

+ (void)setFilename:(NSString *)filename_
{
	if (instance) {
		[instance release];
		instance = nil;
	}
	filename = filename_;
}

+ (Document *)instance
{
	if (!instance) {
		instance = [[Document alloc] init];
	}
	return instance;
}

- (id)init 
{
	if (self = [super init]) {
		self.encrypted = NO;
		self.locked = YES;
		
		// load file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDir = [paths objectAtIndex:0];
		NSString *dataFilePath = [NSString stringWithFormat:@"%@/%@", documentsDir, filename];
		NSData *doc = [fileManager contentsAtPath:dataFilePath];

		// read header
		int hdrlen, enc, docver;
		char algo[25], updt[25];
		if (doc != nil && buffer_read_header((char *)[doc bytes], [doc length], &hdrlen, &enc, algo, &docver, updt) == 0) {
			self.data = [[doc subdataWithRange:NSMakeRange(hdrlen, [doc length] - hdrlen)] retain];
			self.name = filename;
			self.encrypted = (enc != 0);
			self.algorithm = [NSString stringWithFormat:@"%s", (char*)algo];
			self.updated = [NSString stringWithFormat:@"%s", (char*)updt];
		}
	}
	return self;
}

- (Boolean)lock
{
	self.locked = YES;
	return self.locked;
}

- (Boolean)unlockWithPassword:(NSString *)passwd
{
	NSData *xmldata;
	int outlen = [data length];
	char *outbuf = malloc(outlen);
	int rc = 0;
	if (self.encrypted) {
		rc = buffer_decrypt((char *)[passwd UTF8String], (char *)[data bytes], [data length], outbuf, &outlen);
		if (rc == 0) {
			xmldata = [NSData dataWithBytesNoCopy:outbuf length:outlen];
		}
	} else {
		xmldata = self.data;
	}

	if (rc == 0) {
		DocumentParser *parser = [[DocumentParser alloc] initWithData:xmldata];
		[parser setDocumentParserDelegate:self];
		[parser parse];
		[parser release];
		self.locked = NO;
	} else {
		free(outbuf);
	}
	
	return self.locked;
}


- (void)didStartParsing
{
	self.sections = [[NSMutableArray alloc] init];
}

- (void)didEndParsing
{
	NSLog(@"section: %@", self.sections);
}

- (void)addItem:(Item *)item
{
	Section *section = [[Section alloc] init];
	section.name = item.category;
	NSUInteger index = [self.sections indexOfObject:section];
	[section release];
	
	if (index != NSNotFound) {
		section = [self.sections objectAtIndex:index];
	} else {
		section = [[Section alloc] init];
		section.name = item.category;
		section.items = [[NSMutableArray alloc] init];
		[self.sections addObject:section];
	}

	[section.items addObject:item];
}

- (void) dealloc {
	[sections release];
	[super dealloc];
}

@end
