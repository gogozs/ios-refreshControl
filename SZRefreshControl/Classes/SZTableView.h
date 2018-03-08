//
//  SZTableView.h
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import <UIKit/UIKit.h>

@class SZRefreshHeader;
@class SZRefreshFooter;
@interface SZTableView : UITableView

@property (nonatomic) SZRefreshHeader *refreshHeader;
@property (nonatomic) SZRefreshFooter *refreshFooter;

@end
