//
//  Document.h
//  Kryptonotes
//
//  Created by Arvid Juskaitis on 9/23/12.
//  Copyright (c) 2012 Arvid Juskaitis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DocumentModel;
@class Item;

@interface KNDocument : NSDocument <NSTableViewDelegate, NSTableViewDataSource>

@property (unsafe_unretained) IBOutlet NSTextField *nameTextField;
@property (unsafe_unretained) IBOutlet NSComboBox *algorithmComboBox;
@property (unsafe_unretained) IBOutlet NSTextField *updatedTextField;
@property (unsafe_unretained) IBOutlet NSButton *lockButton;

@property (unsafe_unretained) IBOutlet NSTextField *filterTextField;
@property (unsafe_unretained) IBOutlet NSTableView *notesTableView;
@property (unsafe_unretained) IBOutlet NSTextField *categoryTextField;
@property (unsafe_unretained) IBOutlet NSTextField *titleTextField;
@property (unsafe_unretained) IBOutlet NSTextView *contentsTextView;

@property (assign) NSInteger currentRow;
@property (assign) Boolean currentItemIsGroup;

@property (strong) NSData *dataFromFile;
@property (strong) DocumentModel *documentModel;


- (IBAction)lockOrUnlock:(id)sender;
- (IBAction)selectAlgorithm:(id)sender;
- (IBAction)setPassword:(id)sender;
- (IBAction)addCategoryItem:(id)sender;
- (IBAction)addNoteItem:(id)sender;
- (IBAction)saveItem:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)setFilter:(id)sender;

@end
