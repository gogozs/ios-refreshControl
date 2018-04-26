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

// oh, stupid human
static const CGFloat MINI_REFRESH_TIME = 0.4;

@interface SZRefreshHeader()

@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) UIImageView *arrowImageView;

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
        
        _arrowImageView = [UIImageView new];
        [self addSubview:_arrowImageView];
        _arrowImageView.hidden = YES;
        
        [self addSubview:self.spinner];
        [self addSubview:self.tipLabel];
        
        [self _pullDownToRefreshText];
        
        self.tintColor = [UIColor grayColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    _spinner.center = CGPointMake(PADDING + CGRectGetMidX(_spinner.bounds), CGRectGetMidY(self.bounds));
    _arrowImageView.bounds = _spinner.bounds;
    _arrowImageView.center = _spinner.center;
    
    CGFloat tipLabelX = CGRectGetMaxX(_spinner.frame) + PADDING;
    [_tipLabel sizeToFit];
    _tipLabel.frame = CGRectMake(tipLabelX, (height - CGRectGetHeight(_tipLabel.bounds))/2, width - tipLabelX, TIP_LABEL_HEIGHT);
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

- (void)startRefreshResetOffset:(BOOL)reset {
    self.state = SZRefreshHeaderStateLoading;
    [self _loadingText];
    [self startLoading];
    [self _setLoadingContentInsetAnimated:NO resetOffSet:reset];
    [self _loadingStarted];
}

- (void)startRefresh {
    [self startRefreshResetOffset:YES];
}

- (void)stopRefresh {
    [self stopLoading];
    [self _setInitialConentInsetAnimated:YES];
}

- (void)stopRefreshWithTimeInterval:(NSTimeInterval)time {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopRefresh];
        });
    });
}

- (void)deferStopRefresh {
    [self stopRefreshWithTimeInterval:MINI_REFRESH_TIME];
}

#pragma mark - private
- (void)_setInitialConentInsetAnimated:(BOOL)animated {
    _loadingInset = NO;
    _fixedInsetTop = 0;
    
    UIEdgeInsets newInset = _initialInset;
    newInset.top += _fixedInsetTop;
    
    if (UIEdgeInsetsEqualToEdgeInsets(_scrollView.contentInset, newInset)) {
        return;
    }
    
    [_scrollView sz_setContentInset:newInset animated:animated];
}

- (void)_setLoadingContentInsetAnimated:(BOOL)animated resetOffSet:(BOOL)reset {
    _loadingInset = YES;
    _fixedInsetTop = SZ_REFRESH_HEADER_HEIGHT;
    
    UIEdgeInsets inset = _initialInset;
    inset.top += _fixedInsetTop;
    
    if (reset) {
        [_scrollView sz_setContentInsetAndResetOffset:inset animated:animated];
    } else {
        [_scrollView sz_setContentInset:inset animated:animated];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            if (_state == SZRefreshHeaderStateLoading) {
                return;
            }
            
            // can be changed by other methods, needs update it
            [self _updateInset];
            
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
                                [self startRefresh];
                            }
                        }
                    }
                }
            }
            return;
        }
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (void)_loadingStarted {
    if (self.refreshHeaderBlock) {
        self.refreshHeaderBlock();
    }
}

- (void)_pullDownToRefreshText {
    _arrowImageView.image = [[UIImage imageNamed:@"down-arrow" inBundle:[SZBundle imageBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _arrowImageView.hidden = NO;
    
    _tipLabel.text = [SZBundle localizedStringForKey:@"refresh.pull_down_to_refersh"];
}

- (void)_releaseToRefreshText {
    _arrowImageView.image = [[UIImage imageNamed:@"up-arrow" inBundle:[SZBundle imageBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _arrowImageView.hidden = NO;
    
    _tipLabel.text = [SZBundle localizedStringForKey:@"refresh.release_to_refresh"];
}

- (void)_loadingText {
    _arrowImageView.hidden = YES;
    _tipLabel.text = [SZBundle localizedStringForKey:@"refresh.loading"];
    
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

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.font = [UIFont systemFontOfSize:15];
        _tipLabel.textColor = [UIColor grayColor];
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
    _scrollView.alwaysBounceVertical = YES;
    [self _updateInset];
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setState:(SZRefreshHeaderState)state {
    _state = state;
    //    NSLog(@"state:%ld", (long)_state);
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    _arrowImageView.tintColor = tintColor;
}
@end
