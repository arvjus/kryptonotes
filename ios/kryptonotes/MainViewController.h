//
//  MainViewController.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class Document;

@interface MainViewController : UIViewController <UITextFieldDelegate>  {
	UITextField *nameTextField;
	UITextField *algoTextField;
	UITextField *updatedTextField;
	UIButton *lockButton;
	SystemSoundID audioEffect;
	Document *document;
}

@property (retain) IBOutlet UITextField *nameTextField;
@property (retain) IBOutlet UITextField *algoTextField;
@property (retain) IBOutlet UITextField *updatedTextField;
@property (retain) IBOutlet UIButton *lockButton;
@property (assign) Document *document;

- (IBAction)lock:(id)sender;

@end
