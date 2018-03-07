//
//  SZRefreshHeader.m
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import "SZRefreshHeader.h"

const CGFloat SZ_REFRESH_HEADER_HEIGHT = 40;

@interface SZRefreshHeader()

@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation SZRefreshHeader

+ (instancetype)refreshHeaderWithBlock:(SZRefreshHeaderBlock)block {
    SZRefreshHeader *header = [[SZRefreshHeader alloc] init];
    header.refreshHeaderBlock = block;
    
    return header;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
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

- (void)_setLoadingContentInset {
    [self _setContentInsetAndResetOffset:UIEdgeInsetsMake(SZ_REFRESH_HEADER_HEIGHT, 0, 0, 0)];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            CGPoint offset = _scrollView.contentOffset;
            if (fabs(offset.y) >= SZ_REFRESH_HEADER_HEIGHT) { // fully revealed refresh header
                if (_scrollView.decelerating && _state == SZRefreshHeaderStateInitail) {
                    [self startRefresh];
                    _state = SZRefreshHeaderStateLoading;
                    [self _setLoadingContentInset];
                    [self _loadingStarted];
                }
            }
            
            return;
        }
    }
}

- (void)_loadingStarted {
    if (self.refreshHeaderBlock) {
        self.refreshHeaderBlock();
    }
}

#pragma mark - getter
- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}
#pragma mark - setter
- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}
@end
