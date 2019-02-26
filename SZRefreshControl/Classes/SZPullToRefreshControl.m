//
//  SZPullToRefreshControl.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/25.
//

#import "SZPullToRefreshControl.h"
#import "SZRefershDefines.h"

CGFloat const SZPullToRefreshControlHeight = 60;

@interface SZPullToRefreshControl ()

@property (nonatomic, weak) UIScrollView * scrollView;

@property (nonatomic) UILabel *contentLabel;
@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation SZPullToRefreshControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
       
        _refreshState = SZPullToRefreshControlStateStopped;
        _contentLabel = [UILabel new];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_contentLabel];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_spinner];
        
        [self setupInitalState];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.spinner.center = center;
    [self.contentLabel sizeToFit];
    self.contentLabel.center = center;
}

- (void)setupInitalState {
    self.contentLabel.hidden = NO;
    self.contentLabel.text = @"Pull to refresh";
    [self.spinner stopAnimating];
}

#pragma mark - Setter
- (void)setRefreshState:(SZPullToRefreshControlState)refreshState {
    if (_refreshState == refreshState) {
        return;
    }
    
    SZPullToRefreshControlState previousState = _refreshState;
    
    _refreshState = refreshState;
    
    switch (refreshState) {
        case SZPullToRefreshControlStateStopped: {
            [self setupInitalState];
            break;
        }
            
        case SZPullToRefreshControlStateTriggered: {
            self.contentLabel.hidden = NO;
            self.contentLabel.text = @"Release to refresh";
            break;
        }
            
        case SZPullToRefreshControlStateLoading: {
            self.contentLabel.hidden = YES;
            [self.spinner startAnimating];
            
            if (previousState == SZPullToRefreshControlStateTriggered) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            break;
        }
        default:
            break;
    }
}

@end

@interface SZPullToRefreshController ()

@property (nonatomic, weak) UIScrollView * scrollView;

@property (nonatomic) CGFloat initialTopInset;

@end

@implementation SZPullToRefreshController

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)addToScrollView:(UIScrollView *)scrollView {
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    self.scrollView = scrollView;
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.initialTopInset = scrollView.contentInset.top;
    
    SZPullToRefreshControl *refreshControl = [[SZPullToRefreshControl alloc] initWithFrame:CGRectMake(0, -SZPullToRefreshControlHeight, CGRectGetWidth(scrollView.bounds), SZPullToRefreshControlHeight)];
    [scrollView addSubview:refreshControl];
    
    self.refershControl = refreshControl;
}

- (void)beginRefreshing {
    [self changeToState:SZPullToRefreshControlStateTriggered];
    [self changeToState:SZPullToRefreshControlStateLoading];
}

- (void)endRefreshing {
    [self changeToState:SZPullToRefreshControlStateStopped];
}

#pragma mark - Private
- (void)changeToState:(SZPullToRefreshControlState)state {
    self.refershControl.refreshState = state;
    if (SZPullToRefreshControlStateStopped == state) {
        SZLogVerbose(@"restore to pull to refrsh - Stopped");
        [self setInitialInset];
    } else if (SZPullToRefreshControlStateTriggered == state) {
        SZLogVerbose(@"release to refrsh - Triggered");
    } else if (SZPullToRefreshControlStateLoading == state) {
        SZLogVerbose(@"loading - Loading");
        [self setLoadingInset];
    }
}

#pragma mark - ScrollView
- (UIEdgeInsets)actualInset {
    if (@available(iOS 11.0, *)) {
        return self.scrollView.adjustedContentInset;
    } else {
        return self.scrollView.contentInset;
    }
}

- (void)setScrollViewContentInset:(UIEdgeInsets)inset {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = inset;
                     } completion:NULL];
}

- (void)setInitialInset {
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.top = self.initialTopInset;
    
    [self setScrollViewContentInset:inset];
}

- (void)setLoadingInset {
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.top = self.initialTopInset + SZPullToRefreshControlHeight;
    
    [self setScrollViewContentInset:inset];
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
    if (!self.refershControl.enabled) {
        return;
    }
    
    if (self.refershControl.refreshState == SZPullToRefreshControlStateLoading) {
        
    } else {
        static const CGFloat scrollThreshold = SZPullToRefreshControlHeight;
        SZLogVerbose(@"[pullToRefresh] state:%ld, offSet:%lf, contentInset:%@, inset:%@, isDragging:%d", self.refershControl.refreshState, contentOffset.y, NSStringFromUIEdgeInsets(self.scrollView.contentInset), NSStringFromUIEdgeInsets([self actualInset]), self.scrollView.isDragging);
        CGFloat insetTop = [self actualInset].top;
        
        BOOL validOffset = contentOffset.y <= -insetTop-scrollThreshold;
        if (self.refershControl.refreshState == SZPullToRefreshControlStateStopped) {
            if (validOffset && self.scrollView.isDragging) {
                [self changeToState:SZPullToRefreshControlStateTriggered];
            } else {
                SZLogVerbose(@"pull to refrsh");
            }
        } else if (self.refershControl.refreshState == SZPullToRefreshControlStateTriggered) {
            if (validOffset) {
                if (!self.scrollView.isDragging) {
                    [self changeToState:SZPullToRefreshControlStateLoading];
                }
            } else if (self.scrollView.isDragging){
                [self changeToState:SZPullToRefreshControlStateStopped];
            }
        }
    }
}
@end
