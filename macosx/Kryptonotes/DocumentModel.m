//
//  DocumentMgr.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DocumentModel.h"
#import "constants.h"
#import "crypt.h"
#import "Item.h"
#import "DocumentParser.h"
#import "Section.h"


@interface DocumentModel()

- (NSString *)currentTime;
- (NSData *)makeXML;

@end


@implementation DocumentModel

@synthesize encrypted, locked, dirty, name, version, updated, data, dataOffset, password, tmpSections, masterSections, sections;

- (id)init
{
	if (self = [super init]) {
        self.encrypted = NO;
		self.locked = NO;
        self.dirty = NO;

		self.name = @"Untitled.kn";
		self.version = 0;
		self.updated = [self currentTime];

        self.data = nil;
        self.dataOffset = 0;
        self.masterSections = nil;
        self.sections = nil;
        self.filter = @"";
	}
	return self;
}

- (Boolean)setData:(NSData *)documentData andName:(NSString *)documentName error:( NSError **)outError
{
    int hdrlen, enc = 0, docver;
    char algo[25], updt[25];
    if (documentData != nil && buffer_read_header((char *)[documentData bytes], (int)[documentData length], &hdrlen, &enc, algo, &docver, updt) == -1) {
        if (outError) {
            *outError = [NSError errorWithDomain:@"invalid header" code:ERROR_INVALID_HEADER userInfo:nil];
        }
        return NO;
    }

    self.encrypted = (enc != 0);
 
    self.name = documentName;
    self.version = docver;
    self.updated = [NSString stringWithFormat:@"%s", updt];

    self.locked = YES;
    self.dirty = NO;
    
    self.data = documentData;
    self.dataOffset = hdrlen;
    self.masterSections = nil;
    self.sections = nil;
    self.filter = @"";
    return YES;
}

#pragma mark -
#pragma mark lock / unlock

- (Boolean)lockWithError:(__autoreleasing NSError **)outError
{
    if (self.locked) {
        return YES;
    }
	self.data = nil;

    NSData *xmldata = [self makeXML];
    int outbuflen = calculate_output_size((int)[xmldata length]);
    char *outbuf = malloc(outbuflen);
    int rc = 0;

    if (self.encrypted) {
        if (self.password == nil) {
            if (outError) {
                *outError = [NSError errorWithDomain:@"invalid state - missing password" code:ERROR_INVALID_STATE userInfo:nil];
            }
            free(outbuf);
            return NO;
        }

        int hdrlen = buffer_write_header(outbuf, ALGO_BLOWFISH_CBC, self.version);
        int datalen;
        rc = buffer_encrypt((char *)[self.password UTF8String], (char *)[xmldata bytes], (int)[xmldata length], outbuf + hdrlen, &datalen);
        if (rc == 0) {
            outbuflen = hdrlen + datalen;
            self.dataOffset = hdrlen;
        } else {
            self.password = nil;
        }
	} else {
        int hdrlen = buffer_write_header(outbuf, ALGO_NONE, self.version);
        memcpy(outbuf + hdrlen, [xmldata bytes], (int)[xmldata length]);
        outbuflen = hdrlen + (int)[xmldata length];
        self.dataOffset = hdrlen;
	}

    if (rc == 0) {
        self.locked = YES;
        self.data = [NSData dataWithBytesNoCopy:outbuf length:outbuflen];
        self.masterSections = nil;
        self.sections = nil;
        self.filter = @"";
    } else {
        free(outbuf);
    }

    NSLog(@"lockOrError: %@", self.data);
    return YES;
}

- (Boolean)unlockWithError:(__autoreleasing NSError **)outError
{
    if (!self.locked) {
        return YES;
    }
    self.masterSections = nil;
    self.sections = nil;
    self.filter = @"";

	NSData *xmldata = nil;

	if (self.encrypted) {
        if (self.password == nil) {
            if (outError) {
                *outError = [NSError errorWithDomain:@"invalid state - missing password" code:ERROR_INVALID_STATE userInfo:nil];
            }
            return NO;
        }

        int outbuflen = (int)[self.data length];
        char *outbuf = malloc(outbuflen);
        int rc = buffer_decrypt((char *)[self.password UTF8String],
                                (char *)([self.data bytes] + self.dataOffset),
                                (int)([self.data length] - self.dataOffset),
                                outbuf, &outbuflen);
		if (rc == 0) {
			xmldata = [NSData dataWithBytesNoCopy:outbuf length:outbuflen];
        } else {
            self.password = nil;
            free(outbuf);
		}
	} else {
		xmldata = [self.data subdataWithRange:NSMakeRange(self.dataOffset, [self.data length] - self.dataOffset)];
	}
    
    if (xmldata) {
		DocumentParser *parser = [[DocumentParser alloc] initWithData:xmldata];
		[parser setDocumentParserDelegate:self];
		[parser parse];

        self.locked = NO;
    }

    return YES;
}

#pragma mark -
#pragma mark DocumentParserDelegate

- (void)didStartParsing
{
	self.tmpSections = [[NSMutableArray alloc] init];
}

- (void)addItem:(Item *)item
{
	Section *section = [[Section alloc] init];
	section.name = item.category;
	NSUInteger index = [self.tmpSections indexOfObject:section];
	
	if (index != NSNotFound) {
		section = [self.tmpSections objectAtIndex:index];
	} else {
		section = [[Section alloc] init];
		section.name = item.category;
		section.items = [[NSMutableArray alloc] init];
		[self.tmpSections addObject:section];
	}

	[section.items addObject:item];
}

- (void)didEndParsing
{
    for (Section *section in self.tmpSections) {
        [self reindex:section.items];
    }
    self.masterSections = self.tmpSections;
	self.sections = self.tmpSections;
    self.tmpSections = nil;
    NSLog(@"didEndParsing: %@", self.masterSections);
}

- (void)reindex:(NSArray *)array
{
    if (array != nil) {
        NSInteger index = 0;
        for (NSObject *object in array) {
            ((Item *)object).itemIndex = index ++;
        }
    }
}

#pragma mark -
#pragma mark managing sections as flat collection

- (NSInteger)numberOfItems
{
    NSInteger count = 0;
    if (self.sections) {
        for (Section *section in self.sections) {
            count += [section.items count] + 1;
        }
    }
    return count;
}

- (Item *)itemAtPos:(NSInteger)pos
{
    NSInteger index = 0;
    if (self.sections && [self.sections count] > 0) {
        for (Section *section in self.sections) {
            if (pos == index) {
                __autoreleasing Item *item = [[Item alloc] init];
                item.category = section.name;
                item.isGroup = YES;
                return item;
            }
            
            NSInteger count = [section.items count];
            if (pos <= index + count) {
                Item *item = [section.items objectAtIndex:pos - 1 - index];
                return item;
            } else {
                index += count + 1;
            }
        }
    }
    return nil;
}

- (void)setItem:(Item *)item atPos:(NSInteger)pos markAsGroup:(Boolean)isGroup
{
    // Create array for the 1st item
    if (self.masterSections == nil) {
        self.masterSections = [[NSMutableArray alloc] init];
        self.sections = [[NSMutableArray alloc] init];
    }
    
    NSInteger index = 0, sectionindex = 0;
    for (Section *section in self.sections) {
        // Add new item to existing group
        if (pos == -1 && [item.category isEqualToString:section.name]) {
            if (isGroup == NO) {
                if (section.items == nil) {
                    section.items = [[NSMutableArray alloc] init];
                }
                [section.items addObject:item];

                if (self.sections != self.masterSections) {
                    Section *masterSection = [self.masterSections objectAtIndex:sectionindex];
                    if (masterSection.items == nil) {
                        masterSection.items = [[NSMutableArray alloc] init];
                    }
                    [masterSection.items addObject:item];
                    [self reindex:masterSection.items];
                }
            }
            return;
        }
        
        if (pos == index) {
            // Update section name and category for all children
            if (![item.category isEqualToString:section.name]) {
                section.name = item.category;
                for (Item * sectionitem in section.items) {
                    sectionitem.category = item.category;
                }
            }
            return;
        }
        
        // Update item or skip section
        NSInteger count = [section.items count];
        if (pos > -1 && pos <= index + count) {
            Item *currentitem = [section.items objectAtIndex:pos - 1 - index];
            currentitem.category = item.category;
            currentitem.title = item.title;
            currentitem.content = item.content;
            return;
        } else {
            index += count + 1;
        }

        sectionindex ++;
    }
    
    // No match, create section and item
    if (pos == -1) {
        Section *section = [[Section alloc] init];
        section.name = item.category;
        section.items = [[NSMutableArray alloc] initWithCapacity:5];
        if (isGroup == NO) {
            item.itemIndex = 0;
            [section.items addObject:item];
        }
        [self.sections addObject:section];

        if (self.sections != self.masterSections) {
            [self.masterSections addObject:section];
        }
    }
}

- (void)removeItemAtPos:(NSInteger)pos
{
    if (pos == -1) {
        return;
    }
    
    NSInteger index = 0, sectionindex = 0, itemIndex = -1;
    for (Section *section in self.sections) {
        if (pos == index) {
            [self.sections removeObjectAtIndex:sectionindex];
            break;
        }
        
        NSInteger count = [section.items count];
        if (pos <= index + count) {
            itemIndex = ((Item *)[section.items objectAtIndex:pos - 1 - index]).itemIndex;
            [section.items removeObjectAtIndex:pos - 1 - index];
            break;
        } else {
            index += count + 1;
        }

        sectionindex ++;
    }
    
    // update master
    if (self.sections != self.masterSections) {
        if (sectionindex < [self.masterSections count]) {
            if (itemIndex == -1) {
                [self.masterSections removeObjectAtIndex:sectionindex];
            } else {
                Section *masterSection = [self.masterSections objectAtIndex:sectionindex];
                if (itemIndex < [masterSection.items count]) {
                    [masterSection.items removeObjectAtIndex:itemIndex];
                    [self reindex:masterSection.items];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark list filtering methods

- (void)updateFilter:(NSString *)filter
{
    NSString *oldFilter = self.filter;
    self.filter = [filter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([self.filter length] == 0 && [oldFilter length] > 0) {
        NSLog(@"removing filter");
        self.sections = self.masterSections;
    } else if ([self.filter length] > 0) {
        NSLog(@"set filter to %@", self.filter);
        self.sections = [[NSMutableArray alloc] init];
        if (self.masterSections) {
            for (Section *masterSection in self.masterSections) {
                Section *section = [[Section alloc] init];
                section.name = masterSection.name;
                section.items = [[NSMutableArray alloc] init];
                for (Item *masterItem in masterSection.items) {
                    NSRange rangeTitle = [masterItem.title rangeOfString:self.filter options:NSCaseInsensitiveSearch];
                    NSRange rangeContent = [masterItem.content rangeOfString:self.filter options:NSCaseInsensitiveSearch];
                    if (rangeTitle.length > 0 || rangeContent.length > 0) {
                        [section.items addObject:masterItem];
                    }
                }
                
                [self.sections addObject:section];
            }
        }

    }
}


#pragma mark -
#pragma mark private methods

- (NSString *)currentTime
{
    char updtd[25];
    time_t now = time(NULL);
    strftime((char *)updtd, sizeof(updtd), "%Y-%m-%d %H:%M:%S", localtime(&now));
    return [NSString stringWithFormat:@"%s", updtd];
}

- (NSData *)makeXML
{
    NSMutableString *xml = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<items>\n"];
    if (self.sections) {
        for (Section *section in self.sections) {
            for (Item *item in section.items) {
                [xml appendString:[NSString stringWithFormat:@"<item category=\"%@\" title=\"%@\">%@</item>\n", item.category, item.title, item.content]];
            }
        }
    }
    [xml appendString:@"</items>\n"];

    NSData *xmldata = [xml dataUsingEncoding:NSUTF8StringEncoding];
    return xmldata;
}

@end
