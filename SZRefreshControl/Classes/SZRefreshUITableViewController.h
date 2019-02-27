//
//  SZRefreshUITableViewController.h
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2019/2/19.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class SZRefreshFooter;
@class SZPullToRefreshControl;
@class SZPullToRefreshController;
@interface SZRefreshUITableViewController : UITableViewController

@property (nonatomic) SZPullToRefreshController *pullToRefreshController;
@property (nonatomic) SZPullToRefreshController *footerPullToRefreshController;

@property (nullable, nonatomic) SZRefreshFooter *refreshFooterControl; 



@end

NS_ASSUME_NONNULL_END
