//
//  SZPullToRefreshControl.h
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const SZPullToRefreshControlHeight;

typedef NS_ENUM(NSInteger, SZPullToRefreshControlState) {
    SZPullToRefreshControlStateStopped = -1,
    SZPullToRefreshControlStateTriggered,
    SZPullToRefreshControlStateLoading
};

@interface SZPullToRefreshControl : UIControl

@property (nonatomic) SZPullToRefreshControlState refreshState;

- (instancetype)initWithFrame:(CGRect)frame bottomPosition:(BOOL)bottom;

@end

@interface SZPullToRefreshController : NSObject

@property (nonatomic) SZPullToRefreshControl *refershControl;

- (void)addToScrollView:(UIScrollView *)scrollView;
- (void)addToScrollView:(UIScrollView *)scrollView bottom:(BOOL)bottom;

- (void)beginRefreshing;
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
