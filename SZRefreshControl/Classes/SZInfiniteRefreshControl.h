//
//  SZRefreshFooter.h
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import <UIKit/UIKit.h>

extern const CGFloat SZ_INFINITE_REFRESH_HEIGHT;

typedef NS_ENUM(NSInteger, SZInfiniteRefreshControlState) {
    SZInfiniteRefreshStateStopped = -1,
    SZInfiniteRefreshStateTriggered,
    SZInfiniteRefreshStateLoading,
    SZInfiniteRefreshStateFinish,
};

typedef void(^SZRefreshFooterBlock)(void);

@interface SZInfiniteRefreshControl : UIControl

@property (nonatomic) SZInfiniteRefreshControlState refreshState;

@end

@interface SZInfiniteRefreshController : NSObject

@property (nonatomic) SZInfiniteRefreshControl *refershControl;

- (void)addToScrollView:(UIScrollView *)scrollView;

- (void)beginRefreshing;
- (void)endRefreshing;
- (void)finishRefreshing;

- (void)resetState;

@end
