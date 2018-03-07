//
//  UIScrollView+SZRefresh.h
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/6.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZRefreshHeader.h"

extern const CGFloat SZ_REFRESH_HEADER_HEIGHT;

/**
 @note subclass of UIScrollView not update frame from `layoutSubView`, need update manually
 */
@interface UIScrollView (SZRefresh)

@property (nonatomic) SZRefreshHeader *sz_refreshHeader;

@property (nonatomic) SZRefreshHeaderBlock sz_refreshHeaderBlock;

@end
