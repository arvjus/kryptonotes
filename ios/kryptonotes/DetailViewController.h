//
//  DetailViewController.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface DetailViewController : UIViewController {
	UITextField *itemcategory;
	UITextField *itemtitle;
	UITextView *itemcontent;
	
	Item *item;
}

@property (retain) IBOutlet UITextField *itemcategory;
@property (retain) IBOutlet UITextField *itemtitle;
@property (retain) IBOutlet UITextView *itemcontent;

@property (retain) Item *item;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil item:(Item *)item;

@end
