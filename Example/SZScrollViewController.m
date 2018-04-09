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

@property (nonatomic) UIView *view;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *placeHolderView;
@property (nonatomic) UIToolbar *toolbar;
@end

@implementation SZScrollViewController
@dynamic view;

- (void)loadView {
    UIView *container = [UIView new];
    _scrollView = [UIScrollView new];
    [container addSubview:_scrollView];
    
    _placeHolderView = [UIView new];
    _placeHolderView.backgroundColor = [UIColor redColor];
    [_scrollView addSubview:_placeHolderView];
    
    _toolbar = [UIToolbar new];
    [container addSubview:_toolbar];
    
    self.view = container;
    
//    NSLog(@"%@", [SZBundle localizedStringForKey:@"refresh.loading"]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.bottom = 50;
    self.scrollView.contentInset = inset;
    
    __weak typeof(self) wself = self;
    SZRefreshHeader *header = [SZRefreshHeader refreshHeaderWithBlock:^{
        //        NSLog(@"scroll view refreshing...");
        __strong typeof(self) sself = wself;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [sself.scrollView.sz_refreshHeader stopRefresh];
        });
    }];
    
    header.tintColor = [UIColor grayColor];
    header.tipLabel.font = [UIFont systemFontOfSize:15];
    header.tipLabel.textColor = [UIColor grayColor];
    _scrollView.sz_refreshHeader = header;
    
    _scrollView.sz_refreshFooter = [SZRefreshFooter refreshFooterWithBlock:^{
        __strong typeof(self) sself = wself;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [sself.scrollView.sz_refreshFooter stopRefresh];
        });
    }];
    

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    
    _scrollView.frame = CGRectMake(0, 0, w, h);
    _placeHolderView.frame = CGRectMake(0, 0, w, h);
    self.scrollView.contentSize = CGSizeMake(w, h);
    
    _toolbar.frame = CGRectMake(0, h-50, w, 50);
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
