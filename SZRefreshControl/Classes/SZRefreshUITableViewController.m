//
//  SZRefreshUITableViewController.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/19.
//

#import "SZRefreshUITableViewController.h"
#import "SZPullToRefreshControl.h"

@interface SZRefreshUITableViewController ()

@end

@implementation SZRefreshUITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pullToRefreshController = [[SZPullToRefreshController alloc] init];
    [_pullToRefreshController addToScrollView:self.tableView];
    
    _footerPullToRefreshController = [[SZPullToRefreshController alloc] init];
    [_footerPullToRefreshController addToScrollView:self.tableView bottom:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}
@end
