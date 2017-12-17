//
//  ViewController.m
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import "ViewController.h"
#import "SZRefreshHeader.h"

static const CGFloat REFRESH_HEADER_HEIGHT = 40;

typedef NS_ENUM(NSInteger, SZRefreshHeaderState) {
    SZRefreshHeaderStateInitail,
    SZRefreshHeaderStateLoading
};


@interface ViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) SZRefreshHeader *refreshHeader;

@property (nonatomic) UIButton *endRefreshButton;

@property (nonatomic) SZRefreshHeaderState state;

@end

@implementation ViewController

- (void)loadView {
    UIView *container = [UIView new];
    container.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [UIScrollView new];
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    [container addSubview:_scrollView];
    
    _refreshHeader = [SZRefreshHeader new];
    _refreshHeader.backgroundColor = [UIColor redColor];
    [_scrollView addSubview:_refreshHeader];
    
    _endRefreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_scrollView addSubview:_endRefreshButton];
    
    self.view = container;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _state = SZRefreshHeaderStateInitail;
    
    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _scrollView.contentInset = UIEdgeInsetsMake(-REFRESH_HEADER_HEIGHT, 0, 0, 0);
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    [_scrollView addObserver:self forKeyPath:@"decelerating" options:NSKeyValueObservingOptionNew context:NULL];
    [_endRefreshButton setTitle:@"endRefresh" forState:UIControlStateNormal];
    [_endRefreshButton addTarget:self action:@selector(endRefresh:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    _scrollView.frame = self.view.bounds;
    _scrollView.contentSize = CGSizeMake(width, height + 100);
    
    _refreshHeader.frame = CGRectMake(0, 0, width, REFRESH_HEADER_HEIGHT);
    
    [_endRefreshButton sizeToFit];
    _endRefreshButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            CGPoint offset = _scrollView.contentOffset;
            NSLog(@"offsetY:%lf", offset.y);
            if (offset.y <= 0) { // fully revealed refresh header
                [self _startLoading];
                if (_scrollView.decelerating && _state == SZRefreshHeaderStateInitail) {
                    _state = SZRefreshHeaderStateLoading;
                    [self _setLoadingContentInset];
                }
//                NSLog(@"decelerating:%d", _scrollView.decelerating);
            }
            
            return;
        }
        
        if ([keyPath isEqualToString:@"decelerating"]) {
            NSLog(@"decelerating: %d", _scrollView.decelerating);
        }
    }
}

- (void)endRefresh:(id)sender {
    [self _endLoading];
}

- (void)_startLoading {
    [_refreshHeader startLoading];
}

- (void)_endLoading {
    _state = SZRefreshHeaderStateInitail;
    [_refreshHeader stopLoading];
    [self _setInitialConentInsetAnimated:YES];
}

#pragma makr -
- (void)_setInitialConentInsetAnimated:(BOOL)animated {
    UIEdgeInsets newInset = UIEdgeInsetsMake(-REFRESH_HEADER_HEIGHT, 0, 0, 0);
    if (UIEdgeInsetsEqualToEdgeInsets(_scrollView.contentInset, newInset)) {
        return;
    }
    
    
    [self _setContentInset:newInset animated:animated];
}

- (void)_setLoadingContentInset {
    [self _setContentInsetAndResetOffset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)_setContentInset:(UIEdgeInsets)inset animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            _scrollView.contentInset = inset;
        }];
    } else {
        _scrollView.contentInset = inset;
    }
}


/**
 work around for scroll view jumper stutter

 @refre https://stackoverflow.com/a/26320256/1911562
 @param inset contentInset value
 */
- (void)_setContentInsetAndResetOffset:(UIEdgeInsets)inset {
    CGPoint contentOffset = _scrollView.contentOffset;
        
    [UIView animateWithDuration:0.2 animations:^{
        _scrollView.contentInset = inset;
        _scrollView.contentOffset = contentOffset;
    }];
}
@end
