//
//  SZTableViewController.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/6.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "SZTableViewController.h"
#import "SZRefreshControl.h"

@interface SZTableViewController ()

@property (nonatomic) SZTableView *view;
@end

@implementation SZTableViewController

@dynamic view;

- (void)loadView {
    self.view = [SZTableView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) wself = self;
    self.view.refreshHeader = [SZRefreshHeader refreshHeaderWithBlock:^{
        __strong typeof(self) sself = wself;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sself.view.refreshHeader stopRefresh];
        });

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
