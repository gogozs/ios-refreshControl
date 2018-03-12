//
//  UIScrollView+SZExt.h
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (SZExt)

/**
 work around for scroll view jumper stutter
 
 @refer https://stackoverflow.com/a/26320256/1911562
 @param inset contentInset value
 @param animated animation
 */
- (void)sz_setContentInsetAndResetOffset:(UIEdgeInsets)inset animated:(BOOL)animated;

/**
 set contentInset

 @param inset contentInset value
 @param animated animation
 */
- (void)sz_setContentInset:(UIEdgeInsets)inset animated:(BOOL)animated;

- (UIEdgeInsets)sz_contentInset;

@end
