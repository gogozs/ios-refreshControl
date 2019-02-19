//
//  SZRefreshUITableViewController.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/19.
//

#import "SZRefreshUITableViewController.h"
#import "SZRefreshFooter.h"
#import "SZRefreshHeader.h"

@interface SZRefreshUITableViewController ()

@end

@implementation SZRefreshUITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat contentHeight = self.tableView.contentSize.height;
    
    if (_refreshHeaderControl) {
        _refreshHeaderControl.frame = CGRectMake(0, -SZ_REFRESH_HEADER_HEIGHT, width, SZ_REFRESH_HEADER_HEIGHT);
    }
    
    if (_refreshFooterControl) {
        self.refreshFooterControl.frame = CGRectMake(0, MAX(height, contentHeight), width, SZ_REFRESH_FOOTER_HEIGHT);
    }

}

#pragma mark - Getter
- (SZRefreshFooter *)refreshFooterControl {
    if (!_refreshFooterControl) {
        _refreshFooterControl = [SZRefreshFooter refreshFooter];
        _refreshFooterControl.scrollView = self.tableView;
        [self.tableView addSubview:_refreshFooterControl];
    }
    
    return _refreshFooterControl;
}

- (SZRefreshHeader *)refreshHeaderControl {
    if (!_refreshHeaderControl) {
        _refreshHeaderControl = [SZRefreshHeader refreshHeaderWithBlock:^{
            
        }];
        _refreshHeaderControl.scrollView = self.tableView;
        [self.tableView addSubview:_refreshHeaderControl];
    }
    
    return _refreshHeaderControl;
}

@end
