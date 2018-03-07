//
//  UIScrollView+SZRefresh.h
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/6.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZRefreshHeader.h"

@interface UIScrollView (SZRefresh)

@property (nonatomic) SZRefreshHeader *sz_refreshHeader;

@end
