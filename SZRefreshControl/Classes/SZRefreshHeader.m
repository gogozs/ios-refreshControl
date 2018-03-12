//
//  SZRefreshHeader.m
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import "SZRefreshHeader.h"
#import "UIScrollView+SZExt.h"
#import "SZBundle.h"

const CGFloat SZ_REFRESH_HEADER_HEIGHT = 40;
static const CGFloat PADDING = 8;
static const CGFloat TIP_LABEL_HEIGHT = 20;

@interface SZRefreshHeader()

@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) UILabel *tipLabel;

/**
 prevent infinite loop
 */
@property (nonatomic, getter=hasSetLoadingInset) BOOL loadingInset;
@property (nonatomic) UIEdgeInsets initialInset;

@property (nonatomic) CGFloat fixedInsetTop;

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
        self.state = SZRefreshHeaderStateInitial;
        
        [self addSubview:self.spinner];
        [self addSubview:self.tipLabel];
        
        [self _pullDownToRefreshText];
    }
    
    return self;
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    
    _spinner.center = CGPointMake(PADDING + CGRectGetMidX(_spinner.bounds), CGRectGetMidY(self.bounds));
    
    CGFloat tipLabelX = CGRectGetMaxX(_spinner.frame) + PADDING;
    _tipLabel.frame = CGRectMake(tipLabelX, PADDING, width - tipLabelX, TIP_LABEL_HEIGHT);
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - public
- (void)startLoading {
    [_spinner startAnimating];
}

- (void)stopLoading {
    self.state = SZRefreshHeaderStateInitial;
    [_spinner stopAnimating];
}

- (void)startRefresh {
    self.state = SZRefreshHeaderStateLoading;
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
    _fixedInsetTop = 0;
    UIEdgeInsets newInset = _scrollView.contentInset;
    newInset.top = _fixedInsetTop;
    
    if (UIEdgeInsetsEqualToEdgeInsets(_scrollView.contentInset, newInset)) {
        return;
    }
    
    [_scrollView sz_setContentInset:newInset animated:animated];
}

- (void)_setLoadingContentInset {
    _loadingInset = YES;
    _fixedInsetTop = SZ_REFRESH_HEADER_HEIGHT;
    
    UIEdgeInsets inset = self.initialInset;
    inset.top += _fixedInsetTop;
    
    [_scrollView sz_setContentInsetAndResetOffset:inset animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            CGPoint offset = _scrollView.contentOffset;
            CGFloat offsetDelta = offset.y + (_scrollView.sz_contentInset.top - _fixedInsetTop);
//            NSLog(@"dragging:%d, decelerating:%d, offset:%lf, offsetDelta:%lf", _scrollView.isDragging, _scrollView.isDecelerating, offset.y, offsetDelta);
            if (offsetDelta == 0) {
                [self _pullDownToRefreshText];
            }
            
            if (offsetDelta < 0) {
                if (fabs(offsetDelta) >= SZ_REFRESH_HEADER_HEIGHT + 20) {
                    if (_state == SZRefreshHeaderStateInitial) {
                        if (_scrollView.isDragging) {
                            [self _releaseToRefreshText];
                        }
                    }
                } else if(fabs(offsetDelta) >= SZ_REFRESH_HEADER_HEIGHT) {
                    
                    if (_state == SZRefreshHeaderStateInitial) {
                        if (!_scrollView.isDragging) {
                            if (!self.hasSetLoadingInset) {
                                self.state = SZRefreshHeaderStateLoading;
                                [self _loadingText];
                                [self startLoading];
                                [self _setLoadingContentInset];
                                [self _loadingStarted];
                            }
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

- (void)_pullDownToRefreshText {
    _tipLabel.text = [SZBundle localizedStringForKey:@"refresh.pull_down_to_refersh"];
}

- (void)_releaseToRefreshText {
    _tipLabel.text = [SZBundle localizedStringForKey:@"refresh.release_to_refresh"];
}

- (void)_loadingText {
    _tipLabel.text = [SZBundle localizedStringForKey:@"refresh.loading"];

}

#pragma mark - getter
- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
    }
    
    return _tipLabel;
}

- (UIEdgeInsets)actualInset {
    if (@available(iOS 11.0, *)) {
        return _scrollView.adjustedContentInset;
    } else {
        return _scrollView.contentInset;
    }
}

#pragma mark - setter
- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    _scrollView = scrollView;
    _initialInset = _scrollView.contentInset;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setState:(SZRefreshHeaderState)state {
    _state = state;
//    NSLog(@"state:%ld", (long)_state);
}
@end
