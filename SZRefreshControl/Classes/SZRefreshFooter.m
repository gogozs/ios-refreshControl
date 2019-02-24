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

@interface SZRefreshFooter ()

@property (nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) UIEdgeInsets initialInset;

@end

@implementation SZRefreshFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _refreshState = SZRefreshFooterStateStopped;
        

        [self addSubview:self.spinner];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.spinner.center = center;
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - public
- (void)startRefresh {
    SZLog(@"[refreshFooter] start refresh");
    self.refreshState = SZRefreshFooterStateLoading;
}

- (void)stopRefresh {
    SZLog(@"[refreshFooter] stop refresh");
    self.refreshState = SZRefreshFooterStateStopped;
}

- (void)finishRefresh {
    SZLog(@"[refreshFooter] finish refresh");
    self.refreshState = SZRefreshFooterStateFinish;
}

#pragma mark - Scroll View
- (void)setScrollViewContentInset:(UIEdgeInsets)inset {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = inset;
                     } completion:NULL];
}


- (void)setInitailInset {
    UIEdgeInsets inset = _initialInset;
    
    [self setScrollViewContentInset:inset];
}

- (void)setLoadingInset {
    UIEdgeInsets inset = _initialInset;
    inset.bottom += SZ_REFRESH_FOOTER_HEIGHT;
    
    [self setScrollViewContentInset:inset];
}

- (UIEdgeInsets)actualInset {
    if (@available(iOS 11.0, *)) {
        return _scrollView.adjustedContentInset;
    } else {
        return _scrollView.contentInset;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            [self scrollViewDidScroll:self.scrollView.contentOffset];
        }
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if (!self.enabled) {
        return;
    }
    
    if (self.refreshState == SZRefreshFooterStateFinish) {

    } else if (self.refreshState == SZRefreshFooterStateLoading) {
        
    } else {
        CGFloat sizeHeight = self.scrollView.contentSize.height;
        CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.bounds);
        UIEdgeInsets inset = [self actualInset];
        CGFloat scrollOffsetThreshold = sizeHeight - scrollViewHeight - inset.bottom;
        
        SZLogVerbose(@"[refreshFooter] state:%ld, contentOffset.y:%lf, scrollOffsetThreshold:%lf, sizeHeight:%lf, scrollViewHeight:%lf, isDragging:%d, inset:%@, contentInset:%@", (long)self.refreshState, contentOffset.y, scrollOffsetThreshold, sizeHeight, scrollViewHeight, self.scrollView.isDragging, NSStringFromUIEdgeInsets([self actualInset]), NSStringFromUIEdgeInsets(self.scrollView.contentInset));
        BOOL needsTrigged = contentOffset.y > scrollOffsetThreshold;
        if (self.refreshState == SZRefreshFooterStateStopped) {
            if (self.scrollView.isDragging && needsTrigged) {
                SZLog(@"[refreshFooter] change to triggered state");
                self.refreshState = SZRefreshFooterStateTriggered;
            }
        } else if (self.refreshState == SZRefreshFooterStateTriggered) {
            if (!self.scrollView.isDragging) {
                SZLog(@"[refreshFooter] change to loading state, contentOffset.y:%lf, threshold:%lf", contentOffset.y, scrollOffsetThreshold);
                self.refreshState = SZRefreshFooterStateLoading;
            } else if (!needsTrigged) {
                SZLog(@"[refreshFooter] change to stop state, contentOffset.y:%lf, threshold:%lf", contentOffset.y, scrollOffsetThreshold);
                self.refreshState = SZRefreshFooterStateStopped;
            }
        }
    }
}

#pragma mark - Private

#pragma mark - Setter
- (void)setRefreshState:(SZRefreshFooterState)refreshState {
    if (_refreshState == refreshState) {
        return;
    }
    
    SZRefreshFooterState previousState = _refreshState;
    _refreshState = refreshState;
    SZLog(@"[refreshFooter] state changed:%ld", refreshState);
    switch (refreshState) {
        case SZRefreshFooterStateStopped: {
            [self.spinner stopAnimating];
            break;
        }
        case SZRefreshFooterStateTriggered: {
            [self.spinner startAnimating];
            break;
        }
        case SZRefreshFooterStateLoading: {
            [self.spinner startAnimating];
            break;
        }
            
        case SZRefreshFooterStateFinish: {
            [self.spinner stopAnimating];
            [self setInitailInset];
            break;
        }
    }
    
    if (previousState == SZRefreshFooterStateTriggered &&
        refreshState == SZRefreshFooterStateLoading &&
        self.enabled) {
        SZLog(@"[refreshFooter] send action");
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - Getter
- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}

#pragma mark - Setter
- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }

    _scrollView = scrollView;
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.initialInset = _scrollView.contentInset;
    [self setLoadingInset];
}

@end
