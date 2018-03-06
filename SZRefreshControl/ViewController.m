//
//  ViewController.m
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+SZRefresh.h"

@interface ViewController ()

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UIButton *endRefreshButton;

@end

@implementation ViewController

- (void)loadView {
    UIView *container = [UIView new];
    container.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [UIScrollView new];
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    [container addSubview:_scrollView];
    
    
    _endRefreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_scrollView addSubview:_endRefreshButton];
    
    self.view = container;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [_endRefreshButton setTitle:@"endRefresh" forState:UIControlStateNormal];
    [_endRefreshButton addTarget:self action:@selector(endRefresh:) forControlEvents:UIControlEventTouchUpInside];
    
    _scrollView.sz_refreshHeaderBlock = ^{
        NSLog(@"header refreshing...");
    };
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    _scrollView.frame = self.view.bounds;
    _scrollView.contentSize = CGSizeMake(width, height + 100);
    
    [_endRefreshButton sizeToFit];
    _endRefreshButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endRefresh:(id)sender {
    [self _endLoading];
}


- (void)_endLoading {
    [self.scrollView sz_refreshHeaderStopLoading];
}


@end
