//
//  SZTableView.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import "SZTableView.h"
#import "SZRefreshHeader.h"

@implementation SZTableView

- (void)setRefreshHeader:(SZRefreshHeader *)refreshHeader {
    _refreshHeader = refreshHeader;
    
    _refreshHeader.scrollView = self;
    [self addSubview:_refreshHeader];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    _refreshHeader.frame = CGRectMake(0, -SZ_REFRESH_HEADER_HEIGHT, width, SZ_REFRESH_HEADER_HEIGHT);
}

@end
