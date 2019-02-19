//
//  SZRefreshUITableViewController.h
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SZRefreshHeader;
@class SZRefreshFooter;
@interface SZRefreshUITableViewController : UITableViewController

@property (nonatomic) SZRefreshHeader *refreshHeaderControl;
@property (nonatomic) SZRefreshFooter *refreshFooterControl;

@end

NS_ASSUME_NONNULL_END
