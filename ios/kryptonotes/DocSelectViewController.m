//
//  DocSelectViewController.m
//  kryptonotes
//
//  Created by Arvid Juskaitis on 2015-02-16.
//
//

#import "DocSelectViewController.h"
#import "MainViewController.h"
#import "Document.h"


@implementation DocSelectViewController

@synthesize data, tableView;

+ (NSArray *)listAvailableDocuments {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:documentsDir error:nil];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.kn'"];
    return [dirContents filteredArrayUsingPredicate:filter];
}

- (id)initWithNibName:(NSString *)nibName andAvailableDocuments:(NSArray *)availableDocuments {
    if (self = [super initWithNibName:nibName bundle:nil]) {
        self.data = availableDocuments;
        if ([data count] < 5) {
            tableView.scrollEnabled = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*) [tableView_ dequeueReusableCellWithIdentifier:@"SelCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SelCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.font = [UIFont systemFontOfSize:16];
    }
    cell.text = [[data objectAtIndex:indexPath.row] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *docname = [self.data objectAtIndex:indexPath.row];
    [Document setFilename:docname];
    
    MainViewController *controller = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)dealloc{
    [data release];
    [tableView release];
    [super dealloc];
}

@end
