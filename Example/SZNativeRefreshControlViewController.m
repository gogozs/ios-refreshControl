//
//  SZNativeRefreshControlViewController.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "SZNativeRefreshControlViewController.h"

@interface SZNativeRefreshControlViewController ()

@property (nonatomic) UIScrollView *view;
@property (nonatomic) UIView *placeHolderView;
@end

@implementation SZNativeRefreshControlViewController

@dynamic view;

- (void)loadView {
    self.view = [UIScrollView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    self.view.refreshControl = refreshControl;
    
    _placeHolderView = [UIView new];
    _placeHolderView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_placeHolderView];
}

- (void)viewDidLayoutSubviews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    _placeHolderView.frame = CGRectMake(0, 0, w, h);
}

- (void)refreshAction {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view.refreshControl endRefreshing];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
