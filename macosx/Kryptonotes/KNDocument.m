//
//  Document.m
//  Kryptonotes
//
//  Created by Arvid Juskaitis on 9/23/12.
//  Copyright (c) 2012 Arvid Juskaitis. All rights reserved.
//

#import "KNDocument.h"
#import "DocumentModel.h"
#import "Section.h"
#import "Item.h"
#import "constants.h"

#define	POS_ALGO_NONE			0
#define	POS_ALGO_BLOWFISH_CBC	1

@interface KNDocument()

- (Boolean)setPasswordWithConfirmation:(Boolean)confirm;

@end

@implementation KNDocument

@synthesize nameTextField, algorithmComboBox, updatedTextField,
    filterTextField, categoryTextField, titleTextField, contentsTextView,
    dataFromFile, documentModel, currentRow, currentItemIsGroup;

- (id)init
{
    self = [super init];
    if (self) {
		self.documentModel = [[DocumentModel alloc] init];
    }
    return self;
}

- (void)updateViews
{
    [self.lockButton setImage:[NSImage imageNamed:self.documentModel.locked ? @"lock.png" : @"unlock.png"]];

    [self.algorithmComboBox setEditable:!self.documentModel.locked];
    [self.algorithmComboBox setSelectable:!self.documentModel.locked];
}

- (NSString *)windowNibName
{
    return @"KNDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    self.nameTextField.stringValue = self.displayName;
    [self.algorithmComboBox selectItemAtIndex:self.documentModel.encrypted ? POS_ALGO_BLOWFISH_CBC : POS_ALGO_NONE];
    self.updatedTextField.stringValue = self.documentModel.updated;
  
    [self updateViews];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(__autoreleasing NSError **)outError
{
    if (![self.documentModel lockWithError:outError]) {
        return nil;
    }
    [self updateViews];

    return self.documentModel.data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(__autoreleasing NSError **)outError
{
	if (data) {
        if (![self.documentModel setData:data andName:self.displayName error:outError]) {
            return NO;
        }
        [self updateViews];
        return YES;
	}

    if (outError) {
        *outError = [NSError errorWithDomain:@"data not found" code:ERROR_DATA_NOT_FOUND userInfo:nil];
    }
    return NO;
 }

- (void)saveDocument:(id)sender
{
    if (self.documentModel.encrypted && [self.documentModel.password length] == 0) {
        if (![self setPasswordWithConfirmation:YES]) {
            return;
        }
    }

    if (self.documentModel.encrypted && self.algorithmComboBox.indexOfSelectedItem == POS_ALGO_NONE && [self alertChangeToClearText]) {
        return;
    }
    
    [super saveDocument:sender];
    [self updateViews];
}

- (IBAction)lockOrUnlock:(id)sender
{
    if (self.documentModel.encrypted && [self.documentModel.password length] == 0) {
        if (![self setPasswordWithConfirmation:NO]) {
            return;
        }
    }

    __autoreleasing NSError *error;
    if (self.documentModel.locked) {
        [self.documentModel unlockWithError:&error];
    } else {
        [self.documentModel lockWithError:&error];
    }
    
    [self updateViews];
    [self.notesTableView reloadData];
}

- (IBAction)selectAlgorithm:(id)sender
{
    if (!self.documentModel.locked) {
        if (self.documentModel.encrypted && self.algorithmComboBox.indexOfSelectedItem == POS_ALGO_NONE) {
            if ([self alertChangeToClearText]) {
                self.documentModel.encrypted = NO;
            } else {
                [self.algorithmComboBox selectItemAtIndex:POS_ALGO_BLOWFISH_CBC];
            }
        } else if (self.algorithmComboBox.indexOfSelectedItem == POS_ALGO_BLOWFISH_CBC) {
            self.documentModel.encrypted = YES;
        }
//        [self updateChangeCount:];
    }
}

- (IBAction)setPassword:(id)sender
{
    [self setPasswordWithConfirmation:YES];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    if ([anItem action] == @selector(setPassword:)) {
        return (self.documentModel.encrypted && !self.documentModel.locked);
    }

    return [super validateUserInterfaceItem:anItem];
}

- (Boolean)setPasswordWithConfirmation:(Boolean)confirm
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Enter password"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:self.documentModel.password == nil ? @"" : self.documentModel.password];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        self.documentModel.password = [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark list filtering methods

- (IBAction)setFilter: (id)sender {
    [self.documentModel updateFilter:[filterTextField stringValue]];
    [self.notesTableView reloadData];
}

#pragma mark -
#pragma mark table view

-(NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    NSInteger count = 0;
    if (!self.documentModel.locked) {
        count = [self.documentModel numberOfItems];
    }
    return count;
}

- (BOOL) tableView:(NSTableView *)aTableView isGroupRow:(NSInteger)row
{
    Item *item = [self.documentModel itemAtPos:row];
    return item.isGroup;
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row
{
    Item *item = [self.documentModel itemAtPos:row];
    return item.isGroup ? item.category : item.title;
}

-(void) tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.notesTableView.selectedRow;
    Item *item = nil;
    if (row != -1) {
        item = [self.documentModel itemAtPos:row];
    }

    [self displayItem:item];
    self.currentRow = row;
    self.currentItemIsGroup = item.isGroup;
}

#pragma mark -
#pragma mark editing actions

- (IBAction)addCategoryItem:(id)sender
{
    if (!self.documentModel.locked) {
        Item *item = [[Item alloc] init];
        item.category = @"New Category";
        item.title = @"";
        item.content = @"";
        item.isGroup = YES;
        
        [self displayItem:item];
        self.currentRow = -1;
        self.currentItemIsGroup = YES;
    }
}

- (IBAction)addNoteItem:(id)sender
{
    if (!self.documentModel.locked) {
        Item *item = [[Item alloc] init];
        item.title = @"New Note";
        item.content = @"";

        NSInteger row = self.notesTableView.selectedRow;
        if (row != -1) {
            Item *category = [self.documentModel itemAtPos:row];
            item.category = category.category;
        } else {
            item.category = @"New Category";
        }
        
        [self displayItem:item];
        self.currentRow = -1;
        self.currentItemIsGroup = NO;
    }
}

- (IBAction)saveItem:(id)sender
{
    if (!self.documentModel.locked) {
        Item *item = [[Item alloc] init];
        item.category = self.categoryTextField.stringValue;
        item.title = self.titleTextField.stringValue;
        item.content = [NSString stringWithString:[self.contentsTextView string]];
        
        [self.documentModel setItem:item atPos:self.currentRow markAsGroup:self.currentItemIsGroup];
        [self.notesTableView reloadData];
        self.currentRow = -1;
        self.currentItemIsGroup = NO;
        [self displayItem:nil];
    }
}

- (IBAction)removeItem:(id)sender
{
    if (!self.documentModel.locked) {
        NSInteger row = self.notesTableView.selectedRow;
        [self.documentModel removeItemAtPos:row];
        [self.notesTableView reloadData];
        self.currentRow = -1;
        self.currentItemIsGroup = NO;
        [self displayItem:nil];
    }
}

#pragma mark -
#pragma mark private methods

- (void)displayItem:(Item *)item
{
    if (item != nil) {
        self.categoryTextField.stringValue = item.category;
        if (item.isGroup) {
            self.titleTextField.stringValue = @"";
            self.contentsTextView.string = @"";
        } else {
            self.titleTextField.stringValue = item.title;
            self.contentsTextView.string = item.content;
        }
    } else {
        self.categoryTextField.stringValue = @"";
        self.titleTextField.stringValue = @"";
        self.contentsTextView.string = @"";
    }
}

- (Boolean)alertChangeToClearText
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"You are about to disable encryption!"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    return ([alert runModal] == NSAlertDefaultReturn);
}

@end
