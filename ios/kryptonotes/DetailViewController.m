//
//  DetailViewController.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"
#import "Item.h"

@implementation DetailViewController

@synthesize itemcategory, itemtitle, itemcontent, item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil item:(Item *)theitem {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.item = theitem;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	UIFont *font = [UIFont systemFontOfSize:16];
	
	self.itemcategory.text = item.category;
	self.itemcategory.font = font;
	
	self.itemtitle.text = item.title;
	self.itemcategory.font = font;
	
	self.itemcontent.text = item.content;
	self.itemcontent.font = font;

	self.itemcontent.layer.cornerRadius = 8;
	self.itemcontent.clipsToBounds = YES;
	[self.itemcontent.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]]; 
	[self.itemcontent.layer setBorderWidth:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}


@end
