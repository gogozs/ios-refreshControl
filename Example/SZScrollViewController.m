//
//  SZScrollViewController.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/6.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "SZScrollViewController.h"
#import "SZRefreshControl.h"

@interface SZScrollViewController ()

@property (nonatomic) UIScrollView *view;

@end

@implementation SZScrollViewController
@dynamic view;

- (void)loadView {
    self.view = [UIScrollView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) wself = self;
    self.view.sz_refreshHeader = [SZRefreshHeader refreshHeaderWithBlock:^{
        NSLog(@"scroll view refreshing...");
        __strong typeof(self) sself = wself;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [sself.view.sz_refreshHeader stopRefresh];
        });
    }];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    
    self.view.contentSize = CGSizeMake(w, h);
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
