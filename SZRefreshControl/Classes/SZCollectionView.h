//
//  SZCollectionView.h
//  Pods-SZRefreshControl
//
//  Created by songzhou on 2018/4/9.
//

#import <UIKit/UIKit.h>

@class SZRefreshHeader;
@class SZRefreshFooter;
@interface SZCollectionView : UICollectionView

@property (nonatomic) SZRefreshHeader *refreshHeader;
@property (nonatomic) SZRefreshFooter *refreshFooter;

@end
