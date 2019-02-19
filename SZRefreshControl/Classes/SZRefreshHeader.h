//
//  SZRefreshHeader.h
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat SZ_REFRESH_HEADER_HEIGHT;

typedef NS_ENUM(NSInteger, SZRefreshHeaderStyle) {
    SZRefreshHeaderStyleDefault,
    SZRefreshHeaderStyleArrow,
};

typedef NS_ENUM(NSInteger, SZRefreshHeaderState) {
    SZRefreshHeaderStateInitial,
    SZRefreshHeaderStateLoading
};

typedef void(^SZRefreshHeaderBlock)(void);

@interface SZRefreshHeader : UIControl

@property (nonatomic) SZRefreshHeaderState refreshState;

@property (nonatomic, weak) __kindof UIScrollView * scrollView;
@property (nonatomic) UILabel *tipLabel;

+ (instancetype)headerWithStyle:(SZRefreshHeaderStyle)style;

    
- (void)startRefresh;
- (void)stopRefresh;

- (void)deferStopRefresh;

@end
