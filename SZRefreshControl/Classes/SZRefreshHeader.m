//
//  SZRefreshHeader.m
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import "SZRefreshHeader.h"
#import "UIScrollView+SZExt.h"

const CGFloat SZ_REFRESH_HEADER_HEIGHT = 40;

@interface SZRefreshHeader()

@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) CGFloat initialOffSetY;

/**
 prevent infinite loop
 */
@property (nonatomic, getter=hasSetLoadingInset) BOOL loadingInset;
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
        
        _loadingInset = NO;
        _state = SZRefreshHeaderStateInitial;
        
        [self addSubview:self.spinner];
    }
    
    return self;
}

- (void)layoutSubviews {
    _initialOffSetY = _scrollView.contentOffset.y;
    
    _spinner.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - public
- (void)startLoading {
    [_spinner startAnimating];
}

- (void)stopLoading {
    _state = SZRefreshHeaderStateInitial;
    [_spinner stopAnimating];
}

- (void)startRefresh {
    _state = SZRefreshHeaderStateLoading;
    [self startLoading];
}

- (void)stopRefresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopLoading];
        [self _setInitialConentInsetAnimated:YES];
    });
}

#pragma mark - private
- (void)_setInitialConentInsetAnimated:(BOOL)animated {
    _loadingInset = NO;
    UIEdgeInsets newInset = _scrollView.contentInset;
    newInset.top = 0;
    if (UIEdgeInsetsEqualToEdgeInsets(_scrollView.contentInset, newInset)) {
        return;
    }
    
    [_scrollView sz_setContentInset:newInset animated:animated];
}

- (void)_setLoadingContentInset {
    _loadingInset = YES;
    UIEdgeInsets newInset = _scrollView.contentInset;
    newInset.top = SZ_REFRESH_HEADER_HEIGHT;
    
    [_scrollView sz_setContentInsetAndResetOffset:newInset animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            CGPoint offset = _scrollView.contentOffset;
            CGFloat offsetDelta = offset.y - _initialOffSetY;
//            NSLog(@"dragging:%d", _scrollView.isDragging);
            if (offsetDelta < 0 && fabs(offsetDelta) >= SZ_REFRESH_HEADER_HEIGHT) { // fully revealed refresh header
                if (_state == SZRefreshHeaderStateInitial) {
                    [self startRefresh];
                    [self _loadingStarted];
                }
                
                if (_state == SZRefreshHeaderStateLoading) {
                    if (_scrollView.isDecelerating) {
                        if (!self.hasSetLoadingInset) {
                            [self _setLoadingContentInset];
                        }
                    }
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
