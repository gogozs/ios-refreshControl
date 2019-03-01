//
//  SZRefreshFooter.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import "SZInfiniteRefreshControl.h"
#import "SZRefershDefines.h"

const CGFloat SZ_INFINITE_REFRESH_HEIGHT = 60;

@interface SZInfiniteRefreshControl ()

@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation SZInfiniteRefreshControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _refreshState = SZInfiniteRefreshStateStopped;

        [self addSubview:self.spinner];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.spinner.center = center;
}

#pragma mark - Private

#pragma mark - Setter
- (void)setRefreshState:(SZInfiniteRefreshControlState)refreshState {
    if (_refreshState == refreshState) {
        return;
    }
    
    SZInfiniteRefreshControlState previousState = _refreshState;
    _refreshState = refreshState;
    switch (refreshState) {
        case SZInfiniteRefreshStateStopped: {
            [self.spinner stopAnimating];
            break;
        }
        case SZInfiniteRefreshStateTriggered: {
            [self.spinner startAnimating];
            break;
        }
        case SZInfiniteRefreshStateLoading: {
            [self.spinner startAnimating];
            break;
        }
            
        case SZInfiniteRefreshStateFinish: {
            [self.spinner stopAnimating];
            break;
        }
    }
    
    if (previousState == SZInfiniteRefreshStateTriggered &&
        refreshState == SZInfiniteRefreshStateLoading &&
        self.enabled) {
        SZLog(@"[infiniteRefreshControl] send action");
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

@end

@interface SZInfiniteRefreshController ()

@property (nonatomic, weak) UIScrollView * scrollView;

@property (nonatomic) UIEdgeInsets initialInset;

@end

@implementation SZInfiniteRefreshController

- (void)addToScrollView:(UIScrollView *)scrollView {
    if (self.scrollView) {
        [self _removeObservers];
    }
    
    self.scrollView = scrollView;
    
    self.initialInset = self.scrollView.contentInset;
    
    self.refershControl = [SZInfiniteRefreshControl new];
    [scrollView addSubview:self.refershControl];

    [self _addObservers];
    
    [self changeToState:SZInfiniteRefreshStateStopped];
}

- (void)dealloc {
    [self _removeObservers];
}

#pragma mark - public
- (void)beginRefreshing {
    SZLog(@"[infiniteRefreshControl] beginRefreshing");
    [self changeToState:SZInfiniteRefreshStateLoading];
}

- (void)endRefreshing {
    SZLog(@"[infiniteRefreshControl] endRefreshing");
    [self changeToState:SZInfiniteRefreshStateStopped];
}

- (void)finishRefreshing {
    SZLog(@"[infiniteRefreshControl] finishRefreshing");
    [self changeToState:SZInfiniteRefreshStateFinish];
}

- (void)resetState {
    [self changeToState:SZInfiniteRefreshStateStopped];
}

#pragma mark - Private
- (void)_addObservers {
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
}

- (void)_removeObservers {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (UIEdgeInsets)actualInset {
    if (@available(iOS 11.0, *)) {
        return self.scrollView.adjustedContentInset;
    } else {
        return self.scrollView.contentInset;
    }
}

- (void)changeToState:(SZInfiniteRefreshControlState)state {
    self.refershControl.refreshState = state;
    
    if (SZInfiniteRefreshStateFinish == state) {
        [self setInitailInset];
    } else if (SZInfiniteRefreshStateStopped == state) {
        [self setStoppedInset];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            [self scrollViewDidScroll:self.scrollView.contentOffset];
        } else if ([keyPath isEqualToString:@"contentSize"]) {
            [self scrollViewContentSizeDidChange:self.scrollView.contentSize];
        }
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if (!self.refershControl.enabled) {
        return;
    }
    
    if (self.refershControl.refreshState == SZInfiniteRefreshStateFinish) {
    } else if (self.refershControl.refreshState == SZInfiniteRefreshStateLoading) {
        
    } else {
        CGFloat sizeHeight = self.scrollView.contentSize.height;
        CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.bounds);
        UIEdgeInsets inset = [self actualInset];
        CGFloat scrollOffsetThreshold = sizeHeight - scrollViewHeight + (inset.bottom - SZ_INFINITE_REFRESH_HEIGHT);
        
        SZLogVerbose(@"[infiniteRefreshControl] state:%ld, contentOffset.y:%lf, scrollOffsetThreshold:%lf, sizeHeight:%lf, scrollViewHeight:%lf, isDragging:%d, inset:%@, contentInset:%@", (long)self.refershControl.refreshState, contentOffset.y, scrollOffsetThreshold, sizeHeight, scrollViewHeight, self.scrollView.isDragging, NSStringFromUIEdgeInsets([self actualInset]), NSStringFromUIEdgeInsets(self.scrollView.contentInset));
        
        BOOL needsTrigged = contentOffset.y > scrollOffsetThreshold;
        
        if (self.refershControl.refreshState == SZInfiniteRefreshStateStopped) {
            if (self.scrollView.isDragging && needsTrigged) {
                SZLog(@"[infiniteRefreshControl] change to triggered state");
                [self changeToState:SZInfiniteRefreshStateTriggered];
            }
        } else if (self.refershControl.refreshState == SZInfiniteRefreshStateTriggered) {
            if (!self.scrollView.isDragging) {
                SZLog(@"[infiniteRefreshControl] change to loading state, contentOffset.y:%lf, threshold:%lf", contentOffset.y, scrollOffsetThreshold);
                [self changeToState:SZInfiniteRefreshStateLoading];
            } else if (!needsTrigged) {
                SZLog(@"[infiniteRefreshControl] change to stop state, contentOffset.y:%lf, threshold:%lf", contentOffset.y, scrollOffsetThreshold);
                [self changeToState:SZInfiniteRefreshStateStopped];
            }
        }
    }
}

- (void)scrollViewContentSizeDidChange:(CGSize)contentSize {
    self.refershControl.frame = CGRectMake(0, self.scrollView.contentSize.height, CGRectGetWidth(self.scrollView.bounds), SZ_INFINITE_REFRESH_HEIGHT);
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

- (void)setStoppedInset {
    UIEdgeInsets inset = _initialInset;
    inset.bottom += SZ_INFINITE_REFRESH_HEIGHT;
    
    [self setScrollViewContentInset:inset];
}


@end
