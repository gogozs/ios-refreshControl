//
//  SZRefreshHeader.m
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import "SZRefreshHeader.h"

@interface SZRefreshHeader()

@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation SZRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.spinner];
    }
    
    return self;
}

- (void)layoutSubviews {
    _spinner.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark - public
- (void)startLoading {
    [_spinner startAnimating];
}

- (void)stopLoading {
    [_spinner stopAnimating];
}

#pragma mark - getter
- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}

@end
