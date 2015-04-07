//
//  DocSelectViewController.h
//  kryptonotes
//
//  Created by Arvid Juskaitis on 2015-02-16.
//
//

#import <UIKit/UIKit.h>

@interface DocSelectViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
    NSArray *data;
}

@property (nonatomic, retain) NSArray *data;
@property (retain) IBOutlet UITableView *tableView;

+ (NSArray *)listAvailableDocuments;
- (id)initWithNibName:(NSString *)nibName andAvailableDocuments:(NSArray *)availableDocuments;

@end
