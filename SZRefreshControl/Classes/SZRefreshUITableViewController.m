//
//  SZRefreshUITableViewController.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/19.
//

#import "SZRefreshUITableViewController.h"
#import "SZRefreshFooter.h"
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
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat contentHeight = self.tableView.contentSize.height;
    
    if (_refreshFooterControl) {
        self.refreshFooterControl.frame = CGRectMake(0, contentHeight, width, SZ_REFRESH_FOOTER_HEIGHT);
    }
}

#pragma mark - Setter
- (void)setRefreshFooterControl:(SZRefreshFooter *)refreshFooterControl {
    if (_refreshFooterControl) {
        [_refreshFooterControl removeFromSuperview];
    }
    
    _refreshFooterControl = refreshFooterControl;
    _refreshFooterControl.scrollView = self.tableView;

    [self.tableView addSubview:_refreshFooterControl];
}

@end
