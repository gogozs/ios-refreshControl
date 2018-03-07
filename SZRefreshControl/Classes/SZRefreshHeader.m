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
        
        _state = SZRefreshHeaderStateInitail;

        
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
    _state = SZRefreshHeaderStateInitail;
    [_spinner stopAnimating];
}

- (void)startRefresh {
    [self startLoading];
}

- (void)stopRefresh {
    [self stopLoading];
    [self _setInitialConentInsetAnimated:YES];
}

#pragma mark - private
- (void)_setInitialConentInsetAnimated:(BOOL)animated {
    UIEdgeInsets newInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if (UIEdgeInsetsEqualToEdgeInsets(_scrollView.contentInset, newInset)) {
        return;
    }
    
    
    [self _setContentInset:newInset animated:animated];
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

#pragma mark - getter
- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}
@end
