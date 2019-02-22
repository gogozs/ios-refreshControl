//
//  SZRefreshFooter.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import "SZRefreshFooter.h"
#import "UIScrollView+SZExt.h"
#import "SZRefershDefines.h"
#import "SZBundle.h"

const CGFloat SZ_REFRESH_FOOTER_HEIGHT = 40;
static const CGFloat MINI_REFRESH_TIME = 1;
static const NSTimeInterval MAX_REFRESH_INTERVAL = 0.2;

@interface SZRefreshFooter ()

@property (nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) CGFloat initialOffSetY;
@property (nonatomic) UIEdgeInsets initialInset;

@property (nonatomic, getter=hasSetLoadingInset) BOOL loadingInset;

@property (nonatomic) NSTimeInterval lastTimeRefresh;

@property (nonatomic) UILabel *loadMoreLabel;
@property (nonatomic) BOOL footerFullyShow;

@end

@implementation SZRefreshFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _loadingInset = NO;
        _lastTimeRefresh = 0;
        _footerFullyShow = NO;
        _refreshState = SZRefreshFooterStateInitial;
        
        _loadMoreLabel = [UILabel new];
        _loadMoreLabel.textColor = [UIColor grayColor];
        _loadMoreLabel.text = [SZBundle localizedStringForKey:@"refresh.load_more"];
        [self addSubview:_loadMoreLabel];
        
        [self addSubview:self.spinner];
        
        self.footerFullyShow = NO;
        
        [self addTarget:self action:@selector(tapOnFooter:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)layoutSubviews {
    _initialOffSetY = _scrollView.contentOffset.y;
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _spinner.center = center;
    
    [_loadMoreLabel sizeToFit];
    _loadMoreLabel.center = center;
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - public
- (void)startRefresh {
    SZLog(@"[refreshFooter] start refresh");
    
    self.refreshState = SZRefreshFooterStateLoading;
    
    self.loadMoreLabel.hidden = YES;

    [_spinner startAnimating];
}

- (void)stopRefresh {
    SZLog(@"[refreshFooter] stop refresh");
    
    self.refreshState = SZRefreshFooterStateInitial;
    [self _updateLastTimeRefresh];
    
    [self.spinner stopAnimating];
    
    if (self.footerFullyShow) {
        self.loadMoreLabel.hidden = YES;
    } else {
        self.loadMoreLabel.hidden = NO;
    }
    
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
    SZLog(@"[refreshFooter] finish refresh");
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
            [self _showFooterIfNeeded];
            
            if (self.refreshState == SZRefreshFooterStateFinish) {
                return;
            }
            
            if (self.refreshState == SZRefreshFooterStateLoading) {
                return;
            }
            
            [self _updateInset];
            
            CGFloat contentOffSetY = _scrollView.contentOffset.y;
            CGFloat sizeHeight = _scrollView.contentSize.height;
            CGFloat scrollViewHeight = CGRectGetHeight(_scrollView.bounds);
            UIEdgeInsets inset = [self actualInset];
            CGFloat visibleScrollViewHeight = scrollViewHeight - inset.top - inset.bottom;
            CGFloat offsetFromBottom = sizeHeight - visibleScrollViewHeight;
            
            SZLogVerbose(@"state:%ld, contentOffset.y:%lf, offset:%lf, sizeHeight:%lf, visibleScrollViewHeight:%lf, inset:%@, contentInset:%@", (long)self.refreshState,contentOffSetY, offsetFromBottom, sizeHeight, visibleScrollViewHeight, NSStringFromUIEdgeInsets([self actualInset]), NSStringFromUIEdgeInsets(_scrollView.contentInset));
            
            BOOL footerFullyShow = offsetFromBottom < 0 && fabs(offsetFromBottom) >= SZ_REFRESH_FOOTER_HEIGHT;
            self.footerFullyShow = footerFullyShow;
            
            if (!footerFullyShow) {
                if (contentOffSetY > offsetFromBottom + SZ_REFRESH_FOOTER_HEIGHT + inset.bottom - inset.top) {

                    if (self.refreshState == SZRefreshFooterStateInitial) {
                        [self _startRefreshIfNeeded];
                    }
                    
                    if (self.refreshState == SZRefreshFooterStateLoading) {
                        if (!self.hasSetLoadingInset) {
                            [self _setLoadingInset];
                        }
                    }
                }
            }
        }
    }
}

- (void)_setScrollViewContentInset:(UIEdgeInsets)inset {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = inset;
                     } completion:NULL];
}


- (void)_setInitailInset {
    _loadingInset = NO;
    UIEdgeInsets inset = _initialInset;
    
    [self _setScrollViewContentInset:inset];
    
    SZLog(@"[refreshFooter] set initial contentInset: %@, inset:%@", NSStringFromUIEdgeInsets(_scrollView.contentInset), NSStringFromUIEdgeInsets([_scrollView sz_contentInset]));
}

- (void)_setLoadingInset {
    _loadingInset = YES;
    UIEdgeInsets inset = _initialInset;
    inset.bottom += SZ_REFRESH_FOOTER_HEIGHT;
    
    [self _setScrollViewContentInset:inset];
    
   SZLog(@"[refreshFooter] set loading contentInset: %@, inset:%@", NSStringFromUIEdgeInsets(_scrollView.contentInset), NSStringFromUIEdgeInsets([_scrollView sz_contentInset]));
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

- (void)_showFooterIfNeeded {
    self.hidden = _scrollView.contentSize.height == 0;
}

#pragma mark - Action
- (void)tapOnFooter:(UIControl *)sender {
    if (self.footerFullyShow) {
        [self _startRefreshIfNeeded];
    } else {
       
    }
}

#pragma mark - Setter
- (void)setFooterFullyShow:(BOOL)footerFullyShow {
    _footerFullyShow = footerFullyShow;
    
    if (footerFullyShow) { // footer fully show
        SZLogVerbose(@"[refreshFooter] footer fully show");
    } else {
        SZLogVerbose(@"[refreshFooter] footer not fully show");
    }
    
    self.loadMoreLabel.hidden = !footerFullyShow;
}

#pragma mark - Refresh Control
- (void)_startRefreshIfNeeded {
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    NSTimeInterval refreshInterval = now - self.lastTimeRefresh;
    

    SZLogVerbose(@"[refreshFooter] interval: %lf now:%lf, last:%lf", refreshInterval, now, self.lastTimeRefresh);
    // avoid infinite refreshing when request has not results
    if (refreshInterval < MAX_REFRESH_INTERVAL) {
        SZLogVerbose(@"[refreshFooter] time interval invalid");
        [self _updateLastTimeRefresh];
        return;
    } else {
        SZLogVerbose(@"[refreshFooter] <valid>:%lf", refreshInterval);
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
