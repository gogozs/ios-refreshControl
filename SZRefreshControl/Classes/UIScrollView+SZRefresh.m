//
//  UIScrollView+SZRefresh.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/6.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "UIScrollView+SZRefresh.h"
#import <objc/runtime.h>

static const void *SZRefreshHeaderKey = &SZRefreshHeaderKey;

@implementation UIScrollView (SZRefresh)

+ (void)load {
    swizzleMethod([self class], @selector(layoutSubviews), @selector(sz_layoutSubviews));
}

- (void)sz_layoutSubviews {
    [self sz_layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    self.sz_refreshHeader.frame = CGRectMake(0, -SZ_REFRESH_HEADER_HEIGHT, width, SZ_REFRESH_HEADER_HEIGHT);
}

#pragma mark - setter
- (void)setSz_refreshHeader:(SZRefreshHeader *)sz_refreshHeader {
    objc_setAssociatedObject(self, SZRefreshHeaderKey, sz_refreshHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _setup];
}

#pragma mark - getter
- (SZRefreshHeader *)sz_refreshHeader {
    SZRefreshHeader *header = objc_getAssociatedObject(self, SZRefreshHeaderKey);
    return header;
}

#pragma mark -
- (void)_setup {
    SZRefreshHeader *header = self.sz_refreshHeader;
    header.scrollView = self;
    [self addSubview:header];
}


#pragma mark - runtime
void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end
