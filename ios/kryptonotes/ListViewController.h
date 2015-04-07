//
//  ListViewController.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Document;

@interface ListViewController : UITableViewController {
	Document *document;
}

@property (assign) Document *document;

@end
