//
//  ListViewController.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "Document.h"
#import "DetailViewController.h"
#import "Section.h"

@implementation ListViewController

@synthesize document;

#pragma mark -
#pragma mark private methods

- (Item *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [self.document.sections count]) {
		Section *section = [self.document.sections objectAtIndex:indexPath.section];
		if (indexPath.row < [section.items count]) {
			return [section.items objectAtIndex:indexPath.row];
		} 
	}
	return nil;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	self.document = [Document instance];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.document.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < [self.document.sections count]) {
		return [[[self.document.sections objectAtIndex:section] valueForKey:@"items"] count];
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < [self.document.sections count]) {
		return [[[self.document.sections objectAtIndex:section] valueForKey:@"name"] capitalizedString];
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	cell.text = [[self itemAtIndexPath:indexPath] valueForKey:@"title"];
	cell.font = [UIFont systemFontOfSize:16];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil item:[self itemAtIndexPath:indexPath]];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

