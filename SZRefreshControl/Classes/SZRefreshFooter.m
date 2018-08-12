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

@interface SZRefreshFooter ()

@property (nonatomic) SZRefreshFooterBlock block;
@property (nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) CGFloat initialOffSetY;
@property (nonatomic) UIEdgeInsets initialInset;

@property (nonatomic, getter=hasSetLoadingInset) BOOL loadingInset;

@end

@implementation SZRefreshFooter

+ (instancetype)refreshFooterWithBlock:(SZRefreshFooterBlock)block {
    SZRefreshFooter *footer = [SZRefreshFooter new];
    footer.block = block;
    
    return footer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _loadingInset = NO;
        self.state = SZRefreshFooterStateInitial;
        
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
    self.state = SZRefreshFooterStateLoading;
    [_spinner startAnimating];
}

- (void)stopRefresh {
    self.state = SZRefreshFooterStateInitial;

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
    self.state = SZRefreshFooterStateFinish;
    [self.spinner stopAnimating];
    [self _setInitailInset];
}

- (void)resetState {
    self.state = SZRefreshFooterStateInitial;
}

- (void)deferStopRefresh {
    [self stopRefreshWithTimeInterval:MINI_REFRESH_TIME];
}

#pragma mark - private
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            if (_state == SZRefreshFooterStateFinish) {
                return;
            }
            
            if (_state == SZRefreshFooterStateLoading && self.hasSetLoadingInset) {
                return;
            }
            
            [self _updateInset];
            
            CGFloat contentOffSetY = _scrollView.contentOffset.y;
            CGFloat sizeHeight = _scrollView.contentSize.height;
            CGFloat scrollViewHeight = CGRectGetHeight(_scrollView.bounds);
            UIEdgeInsets inset = [self actualInset];
            CGFloat offset = SZ_REFRESH_FOOTER_HEIGHT + sizeHeight + inset.bottom - scrollViewHeight;
            SZLog(@"state:%ld, contentOffset.y:%lf, offset:%lf, sizeHeight:%lf, scrollViewHeight:%lf, inset:%@", (long)_state,contentOffSetY, offset, sizeHeight, scrollViewHeight, NSStringFromUIEdgeInsets([self actualInset]));
            if (offset > 0 &&
                contentOffSetY > offset) {
                if (self.state == SZRefreshFooterStateInitial) {
                    [self startRefresh];
                    [self _startLoading];
                    
                }
                
                if (_state == SZRefreshFooterStateLoading) {
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
    if (self.block) {
        self.block();
    }
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

- (void)setState:(SZRefreshFooterState)state {
    _state = state;
}
@end
