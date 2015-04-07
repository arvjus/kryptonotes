//
//  MainViewController.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "Document.h"
#import "ListViewController.h"


@interface MainViewController ()

- (void)setElementsForLockState:(Boolean)locked withError:(Boolean)error;

@end


@implementation MainViewController

@synthesize nameTextField, algoTextField, updatedTextField, lockButton, document;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	document = [Document instance];

	UIFont *font = [UIFont systemFontOfSize:16];

	nameTextField.text = document.name;
	nameTextField.font = font;
	
	algoTextField.text = document.algorithm;
	algoTextField.font = font;
	
	updatedTextField.text = document.updated;
	updatedTextField.font = font;
}

- (void)viewDidUnload 
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)performRight:(id)sender 
{
	ListViewController *controller = [[ListViewController alloc] initWithNibName:@"ListView" bundle:nil];
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)lock:(id)sender 
{
	if (document.locked) {
		if (document.encrypted) {
			UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Password"
																	message:@"Please enter the password\n"
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
														  otherButtonTitles:NSLocalizedString(@"Unlock",nil), nil];
            passwordAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
			[passwordAlert show];
			[passwordAlert release];
		} else {
			[document unlockWithPassword:nil];
			[self setElementsForLockState:document.locked withError:NO];
		}
	} else {
		[document lock];
		[self setElementsForLockState:document.locked withError:NO];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Clicked the Submit button
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		[document unlockWithPassword:[[alertView textFieldAtIndex:0] text]];
		[self setElementsForLockState:document.locked withError:document.locked];
	}
}

- (void)setElementsForLockState:(Boolean)locked withError:(Boolean)error
{
	UIImage *btnImage = [UIImage imageNamed:locked ? @"lock.png" : @"unlock.png"];
	[lockButton setImage:btnImage forState:UIControlStateNormal];

    NSString *path  = [[NSBundle mainBundle] pathForResource:locked ? (error ? @"error" : @"lock") : @"unlock" ofType:@"caf"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *pathURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    } else {
        NSLog(@"error, file not found: %@", path);
    }

	if (locked) {
		self.navigationItem.rightBarButtonItem = nil;
	} else {
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"List" 
																		style:UIBarButtonItemStylePlain target:self action:@selector(performRight:)];
		[self.navigationItem setRightBarButtonItem:rightButton animated:NO];
		[rightButton release];
	}
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	AudioServicesDisposeSystemSoundID(audioEffect);
    [super dealloc];
}

@end

