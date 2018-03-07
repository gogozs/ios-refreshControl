//
//  SZRefreshHeader.h
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat SZ_REFRESH_HEADER_HEIGHT;

typedef NS_ENUM(NSInteger, SZRefreshHeaderState) {
    SZRefreshHeaderStateInitail,
    SZRefreshHeaderStateLoading
};

typedef void(^SZRefreshHeaderBlock)(void);

@interface SZRefreshHeader : UIView

@property (nonatomic) SZRefreshHeaderState state;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic) SZRefreshHeaderBlock refreshHeaderBlock;

- (void)startRefresh;
- (void)stopRefresh;

+ (instancetype)refreshHeaderWithBlock:(SZRefreshHeaderBlock)block;

@end
