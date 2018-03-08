//
//  UIScrollView+SZExt.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/7.
//

#import "UIScrollView+SZExt.h"

@implementation UIScrollView (SZExt)

- (void)sz_setContentInsetAndResetOffset:(UIEdgeInsets)inset animated:(BOOL)animated {
    CGPoint contentOffset = self.contentOffset;
    
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
            self.contentInset = inset;
            self.contentOffset = contentOffset;
        }];
    } else {
        self.contentInset = inset;
        self.contentOffset = contentOffset;
    }
}

- (void)sz_setContentInset:(UIEdgeInsets)inset animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
            self.contentInset = inset;
        }];
    } else {
        self.contentInset = inset;
    }
}


@end
