//
//  SZRefreshHeader.h
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SZRefreshHeaderState) {
    SZRefreshHeaderStateInitail,
    SZRefreshHeaderStateLoading
};

typedef void(^SZRefreshHeaderBlock)(void);

@interface SZRefreshHeader : UIView

@property (nonatomic) SZRefreshHeaderState state;

@property (nonatomic, weak) UIScrollView *scrollView;

- (void)startRefresh;
- (void)stopRefresh;

@end
