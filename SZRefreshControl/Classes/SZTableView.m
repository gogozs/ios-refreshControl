//
//  SZTableView.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import "SZTableView.h"
#import "SZRefreshHeader.h"
#import "SZRefreshFooter.h"

@implementation SZTableView

- (void)setRefreshHeader:(SZRefreshHeader *)refreshHeader {
    _refreshHeader = refreshHeader;
    
    _refreshHeader.scrollView = self;
    [self addSubview:_refreshHeader];
}

- (void)setRefreshFooter:(SZRefreshFooter *)refreshFooter {
    _refreshFooter = refreshFooter;
    
    _refreshFooter.scrollView = self;
    [self addSubview:_refreshFooter];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat contentHeight = self.contentSize.height;
    
    if (_refreshHeader) {
        _refreshHeader.frame = CGRectMake(0, -SZ_REFRESH_HEADER_HEIGHT, width, SZ_REFRESH_HEADER_HEIGHT);
    }

    if (_refreshFooter) {
        _refreshFooter.frame = CGRectMake(0, MAX(height, contentHeight), width, SZ_REFRESH_FOOTER_HEIGHT);
    }

}

@end
