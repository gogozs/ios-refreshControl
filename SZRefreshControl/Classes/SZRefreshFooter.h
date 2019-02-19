//
//  SZRefreshFooter.h
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import <UIKit/UIKit.h>

extern const CGFloat SZ_REFRESH_FOOTER_HEIGHT;

typedef NS_ENUM(NSInteger, SZRefreshFooterState) {
    SZRefreshFooterStateInitial,
    SZRefreshFooterStateLoading,
    SZRefreshFooterStateFinish,
};

typedef void(^SZRefreshFooterBlock)(void);

@interface SZRefreshFooter : UIControl

@property (nonatomic) SZRefreshFooterState refreshState;
@property (nonatomic, weak) __kindof UIScrollView * scrollView;

- (void)startRefresh;
- (void)stopRefresh;
- (void)finishRefresh;
- (void)resetState;

- (void)deferStopRefresh;

+ (instancetype)refreshFooter;

@end
