//
//  SZPullToRefreshControl.m
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/25.
//

#import "SZPullToRefreshControl.h"
#import "SZRefershDefines.h"
#import "SVPullToRefreshArrow.h"

CGFloat const SZPullToRefreshControlHeight = 60;

@interface SZPullToRefreshControl ()

@property (nonatomic, weak) UIScrollView * scrollView;

@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) SVPullToRefreshArrow *arrowView;

@property (nonatomic) BOOL bottom;

@end

@implementation SZPullToRefreshControl

- (instancetype)initWithFrame:(CGRect)frame bottomPosition:(BOOL)bottom {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _bottom = bottom;
        _refreshState = SZPullToRefreshControlStateStopped;
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_spinner];
        
        _arrowView = [[SVPullToRefreshArrow alloc] init];
        [self addSubview:_arrowView];
        
        [self setupInitalState];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame bottomPosition:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.spinner.center = center;
    self.arrowView.center = center;
}

- (void)setupInitalState {
    [self rotateArrow:self.bottom ? M_PI : 0 hide:NO];
    [self.spinner stopAnimating];
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrowView.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
        self.arrowView.layer.opacity = !hide;
    } completion:NULL];
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
            SZLog(@"[refreshControl] set refreshState stopped");
            break;
        }
            
        case SZPullToRefreshControlStateTriggered: {
            [self rotateArrow:self.bottom ? 0 : M_PI hide:NO];
            SZLog(@"[refreshControl] set refreshState triggered");
            break;
        }
            
        case SZPullToRefreshControlStateLoading: {
            [self rotateArrow:self.bottom ? M_PI : 0 hide:YES];
            [self.spinner startAnimating];
            SZLog(@"[refreshControl] set refreshState loading");
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

@property (nonatomic) BOOL bottom;

@property (nonatomic, weak) UIScrollView * scrollView;

@property (nonatomic) CGFloat initialTopInset;
@property (nonatomic) CGFloat initialBottomInset;

@end

@implementation SZPullToRefreshController

- (instancetype)init {
    self = [super init];
    if (self) {
        _bottom = NO;
    }
    return self;
}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    if (self.bottom) {
        [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    }
}

- (void)addToScrollView:(UIScrollView *)scrollView {
    [self addToScrollView:scrollView bottom:NO];
}

- (void)addToScrollView:(UIScrollView *)scrollView bottom:(BOOL)bottom {
    self.bottom = bottom;
    
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        if (self.bottom) {
            [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
        }
    }
    
    self.scrollView = scrollView;
    
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    
    if (self.bottom) {
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
        
        self.initialBottomInset = scrollView.contentInset.bottom;
        self.initialTopInset = scrollView.contentInset.top;
        
        SZPullToRefreshControl *refreshControl = [[SZPullToRefreshControl alloc] initWithFrame:CGRectZero bottomPosition:YES];
        [scrollView addSubview:refreshControl];
        [self updateRefreshControlFrameIfNeeded];
        
        self.refershControl = refreshControl;
    } else {
        self.initialTopInset = scrollView.contentInset.top;
        
        SZPullToRefreshControl *refreshControl = [[SZPullToRefreshControl alloc] initWithFrame:CGRectMake(0, -SZPullToRefreshControlHeight, CGRectGetWidth(scrollView.bounds), SZPullToRefreshControlHeight)];
        [scrollView addSubview:refreshControl];
        
        self.refershControl = refreshControl;
    }
    
  
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
        if (self.bottom) {
            [self setFooterInitialInset];
        } else {
            [self setInitialInset];
        }
    } else if (SZPullToRefreshControlStateTriggered == state) {
    } else if (SZPullToRefreshControlStateLoading == state) {
        if (self.bottom) {
            [self setFooterLoadingInset];
        } else {
            [self setLoadingInset];
        }
    }
}

- (void)updateRefreshControlFrameIfNeeded {
    if (self.refershControl.refreshState == SZPullToRefreshControlStateLoading) {
        UIEdgeInsets inset = [self actualInset];
        CGFloat contentSizeHeight = self.scrollView.contentSize.height;
        CGFloat validScrollViewHeight = CGRectGetHeight(self.scrollView.bounds) - inset.top - inset.bottom - SZPullToRefreshControlHeight;
        
        CGFloat originY = MAX(validScrollViewHeight, contentSizeHeight);
        
        self.refershControl.frame = CGRectMake(0, originY, CGRectGetWidth(self.scrollView.bounds), SZPullToRefreshControlHeight);
    } else {
        UIEdgeInsets inset = [self actualInset];
        CGFloat contentSizeHeight = self.scrollView.contentSize.height + inset.bottom;
        CGFloat validScrollViewHeight = CGRectGetHeight(self.scrollView.bounds) - inset.top ;
        
        CGFloat originY = MAX(validScrollViewHeight, contentSizeHeight);
        
        self.refershControl.frame = CGRectMake(0, originY, CGRectGetWidth(self.scrollView.bounds), SZPullToRefreshControlHeight);
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

- (void)setFooterInitialInset {
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.top = self.initialTopInset;
    inset.bottom = self.initialBottomInset;
    
    [self setScrollViewContentInset:inset];
}


- (void)setLoadingInset {
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.top = self.initialTopInset + SZPullToRefreshControlHeight;
    
    [self setScrollViewContentInset:inset];
}

- (void)setFooterLoadingInset {
    BOOL canScroll = self.scrollView.contentSize.height >= (CGRectGetHeight(self.scrollView.bounds) - [self actualInset].top - [self actualInset].bottom) + SZPullToRefreshControlHeight;
    
    UIEdgeInsets inset = self.scrollView.contentInset;
    if (canScroll) {
        inset.bottom = self.initialBottomInset + SZPullToRefreshControlHeight;
    } else {
        inset.top = self.initialTopInset - SZPullToRefreshControlHeight;
    }

    
    [self setScrollViewContentInset:inset];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            [self scrollViewDidScroll:self.scrollView.contentOffset bottom:self.bottom];
        } else if ([keyPath isEqualToString:@"contentSize"]) {
            [self scrollViewDidChangeContentSize:self.scrollView.contentSize];
        }
    }
    
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset bottom:(BOOL)bottom {
    if (!self.refershControl.enabled) {
        return;
    }
    
    if (bottom) {
        [self scrollViewDidScrollWithFooter:contentOffset];
    } else {
        [self scrollViewDidScrollWithHeader:contentOffset];
    }
}

- (void)scrollViewDidChangeContentSize:(CGSize)contentSize {
    if (!self.bottom) {
        return;
    }
    
    [self updateRefreshControlFrameIfNeeded];
}

- (void)scrollViewDidScrollWithHeader:(CGPoint)contentOffset {
    if (self.refershControl.refreshState == SZPullToRefreshControlStateLoading) {
        
    } else {
        static const CGFloat scrollThreshold = SZPullToRefreshControlHeight;
        SZLogVerbose(@"[refreshHeader] state:%ld, offSet:%lf, contentInset:%@, inset:%@, isDragging:%d", self.refershControl.refreshState, contentOffset.y, NSStringFromUIEdgeInsets(self.scrollView.contentInset), NSStringFromUIEdgeInsets([self actualInset]), self.scrollView.isDragging);
        CGFloat insetTop = [self actualInset].top;
        
        BOOL validOffset = contentOffset.y <= -insetTop-scrollThreshold;
        if (self.refershControl.refreshState == SZPullToRefreshControlStateStopped) {
            if (validOffset && self.scrollView.isDragging) {
                SZLog(@"[refreshHeader] - triggered");
                [self changeToState:SZPullToRefreshControlStateTriggered];
            } else {
            }
        } else if (self.refershControl.refreshState == SZPullToRefreshControlStateTriggered) {
            if (validOffset) {
                if (!self.scrollView.isDragging) {
                    SZLog(@"[refreshHeader] - loading");
                    [self changeToState:SZPullToRefreshControlStateLoading];
                }
            } else if (self.scrollView.isDragging){
                SZLog(@"[refreshHeader] - stopped");
                [self changeToState:SZPullToRefreshControlStateStopped];
            }
        }
    }
}

- (void)scrollViewDidScrollWithFooter:(CGPoint)contentOffset {
      SZLogVerbose(@"[refreshFooter] state:%ld, offSet:%lf, sizeHeight:%lf, scrollViewHeight:%lf, contentInset:%@, inset:%@, isDragging:%d", self.refershControl.refreshState, contentOffset.y, self.scrollView.contentSize.height, CGRectGetHeight(self.scrollView.bounds), NSStringFromUIEdgeInsets(self.scrollView.contentInset), NSStringFromUIEdgeInsets([self actualInset]), self.scrollView.isDragging);
    
    if (self.refershControl.refreshState == SZPullToRefreshControlStateLoading) {
        
    } else {
        UIEdgeInsets inset = [self actualInset];
        
        // additional content needs to be scrolled
        CGFloat scrollContentOffSet = MAX(0, self.scrollView.contentSize.height - (CGRectGetHeight(self.scrollView.bounds) - inset.top - inset.bottom));
        CGFloat scrollOffsetThreshold = -inset.top + inset.bottom + SZPullToRefreshControlHeight + scrollContentOffSet;

        BOOL validOffset = contentOffset.y >= scrollOffsetThreshold;
        
        if (self.refershControl.refreshState == SZPullToRefreshControlStateStopped) {
            if (validOffset && self.scrollView.isDragging) {
                SZLog(@"[refreshFooter] - triggered");
                [self changeToState:SZPullToRefreshControlStateTriggered];
            } else {
            }
        } else if (self.refershControl.refreshState == SZPullToRefreshControlStateTriggered) {
            if (validOffset) {
                if (!self.scrollView.isDragging) {
                    SZLog(@"[refreshFooter] - loading");
                    [self changeToState:SZPullToRefreshControlStateLoading];
                }
            } else if (self.scrollView.isDragging){
                SZLog(@"[refreshFooter] - stopped");
                [self changeToState:SZPullToRefreshControlStateStopped];
            }
        }
    }
}

@end
