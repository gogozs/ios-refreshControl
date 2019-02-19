//
//  SZRefreshFooter.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import "SZRefreshFooter.h"
#import "UIScrollView+SZExt.h"
#import "SZRefershDefines.h"

const CGFloat SZ_REFRESH_FOOTER_HEIGHT = 40;
static const CGFloat MINI_REFRESH_TIME = 1;
static const NSTimeInterval MAX_REFRESH_INTERVAL = 0.2;

@interface SZRefreshFooter ()

@property (nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) CGFloat initialOffSetY;
@property (nonatomic) UIEdgeInsets initialInset;

@property (nonatomic, getter=hasSetLoadingInset) BOOL loadingInset;

@property (nonatomic) NSTimeInterval lastTimeRefresh;

@end

@implementation SZRefreshFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _loadingInset = NO;
        _lastTimeRefresh = 0;
        _refreshState = SZRefreshFooterStateInitial;
        
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
- (void)startRefresh {
    self.refreshState = SZRefreshFooterStateLoading;
    [_spinner startAnimating];
}

- (void)stopRefresh {
    self.refreshState = SZRefreshFooterStateInitial;
    [self _updateLastTimeRefresh];
    
    [self.spinner stopAnimating];
    [self _setInitailInset];
}

- (void)stopRefreshWithTimeInterval:(NSTimeInterval)time {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopRefresh];
        });
    });
}

- (void)finishRefresh {
    self.refreshState = SZRefreshFooterStateFinish;
    [self.spinner stopAnimating];
    [self _setInitailInset];
}

- (void)resetState {
    self.refreshState = SZRefreshFooterStateInitial;
}

- (void)deferStopRefresh {
    [self _updateLastTimeRefresh];
    [self stopRefreshWithTimeInterval:MINI_REFRESH_TIME];
}

#pragma mark - private
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            if (self.refreshState == SZRefreshFooterStateFinish) {
                return;
            }
            
            if (self.refreshState == SZRefreshFooterStateLoading && self.hasSetLoadingInset) {
                return;
            }
            
            [self _updateInset];
            
            CGFloat contentOffSetY = _scrollView.contentOffset.y;
            CGFloat sizeHeight = _scrollView.contentSize.height;
            CGFloat scrollViewHeight = CGRectGetHeight(_scrollView.bounds);
            UIEdgeInsets inset = [self actualInset];
            CGFloat offset = sizeHeight + inset.bottom + SZ_REFRESH_FOOTER_HEIGHT - scrollViewHeight;
            SZLog(@"state:%ld, contentOffset.y:%lf, offset:%lf, sizeHeight:%lf, scrollViewHeight:%lf, inset:%@", (long)self.refreshState,contentOffSetY, offset, sizeHeight, scrollViewHeight, NSStringFromUIEdgeInsets([self actualInset]));
            if (offset > 0 &&
                contentOffSetY > offset) {
                if (self.refreshState == SZRefreshFooterStateInitial) {
                    [self _startRefreshIfNeeded];
                }
                
                if (self.refreshState == SZRefreshFooterStateLoading) {
                    if (_scrollView.isDecelerating) {
                        if (!self.hasSetLoadingInset) {
                            [self _setLoadingInset];
                        }
                    }
                }
            }
        }
    }
}

- (void)_setInitailInset {
    _loadingInset = NO;
    UIEdgeInsets inset = _initialInset;
    [_scrollView sz_setContentInset:inset animated:YES];
}

- (void)_setLoadingInset {
    _loadingInset = YES;
    UIEdgeInsets inset = _initialInset;
    inset.bottom += SZ_REFRESH_FOOTER_HEIGHT;
    [_scrollView sz_setContentInsetAndResetOffset:inset animated:YES];
}

- (void)_startLoading {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (UIEdgeInsets)actualInset {
    if (@available(iOS 11.0, *)) {
        return _scrollView.adjustedContentInset;
    } else {
        return _scrollView.contentInset;
    }
}

- (void)_updateInset {
    _initialInset = _scrollView.contentInset;
}

#pragma mark - Refresh Control
- (void)_startRefreshIfNeeded {
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    NSTimeInterval refreshInterval = now - self.lastTimeRefresh;
    
    SZLog(@"footer refresh interval: %lf now:%lf, last:%lf", refreshInterval, now, self.lastTimeRefresh);
    // avoid infinite refreshing when request has not results
    if (refreshInterval < MAX_REFRESH_INTERVAL) {
        SZLog(@"footer refresh invalid");
        [self _updateLastTimeRefresh];
        return;
    } else {
        SZLog(@"footer refresh <valid>:%lf", refreshInterval);
    }
    
    [self startRefresh];
    [self _startLoading];
}

- (void)_updateLastTimeRefresh {
    self.lastTimeRefresh = [NSDate date].timeIntervalSince1970;
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
    [self _updateInset];
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

@end
