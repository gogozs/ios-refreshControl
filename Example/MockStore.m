//
//  MockStore.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/8/12.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "MockStore.h"

NSString *const MockStoreDidGetDataNotification = @"MockStoreDidGetDataNotification";
NSString *const MockStorePagingFinishedKey = @"MockStorePagingFinishedKey";

static const NSUInteger DEFAULT_COUNT = 60;

@interface MockStore ()

@property (nonatomic) NSUInteger total;

@end

@implementation MockStore

- (instancetype)init {
    self = [super init];
    if (self) {
        _total = DEFAULT_COUNT;
        _pagingQueue = dispatch_queue_create("paging queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)getMockDataWithResponseTime:(NSInteger)time success:(void(^)(NSArray<NSString *> *))success {
    NSLog(@"%s", __func__);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray<NSString *> *ret = [NSMutableArray arrayWithCapacity:20];
 
        static const NSUInteger page = 3;
        static const NSUInteger total = 40;
        
        if (!self.data) {
            for (int i = 0; i < page; i++) {
                [ret addObject:@(i).stringValue];
            }
            self.data = [ret copy];
        } else {
            if (self.data.count > total) {
                NSLog(@"request finished");
            } else {
                for (int i = (int)self.data.count; i < self.data.count + page; i++) {
                    [ret addObject:@(i).stringValue];
                }
                
                self.data = [self.data arrayByAddingObjectsFromArray:ret];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MockStoreDidGetDataNotification object:self];
        
        if (success) {
            success(self.data);
        }
    });
}

- (void)_pagingWithPageSize:(NSUInteger)pageSize {
    NSUInteger pages = ceilf((float)self.total/pageSize);
    
    NSUInteger total = self.total;
    NSMutableArray *pageData = [NSMutableArray arrayWithCapacity:pages];
    NSUInteger data = 0;
    for (int i = 0; i < pages; i++) {
        NSUInteger currentSize = total < pageSize ? total : pageSize;
        NSMutableArray *currentData = [NSMutableArray arrayWithCapacity:currentSize];
        for (int j = 0; j < currentSize; j++) {
            [currentData addObject:@(++data)];
        }
        pageData[i] = [currentData copy];
        
        total -= currentSize;
    }
    
    self.pageData = [pageData copy];
}

- (NSArray *)dataWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize {
    if (!self.pageData) {
        [self _pagingWithPageSize:pageSize];
    }
    
    if (page >= self.pageData.count) {
        return @[];
    }
    
    return self.pageData[page];
}

- (void)getMockDataWithResponseTime:(NSInteger)time
                               page:(NSUInteger)page
                           pageSize:(NSUInteger)pageSize
                            success:(void(^)(NSArray<NSString *> *))success {
    NSLog(@"getMockData page request:%lu, pagSize:%lu", page, (unsigned long)pageSize);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *ret = [self dataWithPage:page-1 pageSize:pageSize];
        NSLog(@"getMockData page resp:%lu, pagSize:%lu data:%lu", page, (unsigned long)pageSize, ret.count);
        
        if (page == 1) {
            self.data = ret;
        } else {
            self.data = [self.data arrayByAddingObjectsFromArray:ret];
        }
        
        
        
        if (success) {
            success(ret);
        }
    });
}

- (void)getMockDataWithResponseTime:(NSInteger)time
                               page:(SZPageOperationQueue *)pageQueue
                            success:(void(^)(NSArray<NSString *> *))success {
    NSUInteger page = pageQueue.page;
    NSUInteger pageSize = pageQueue.pageSize;
    
    NSLog(@"getMockData page request:%lu, pagSize:%lu", page, (unsigned long)pageSize);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *ret = [self dataWithPage:page-1 pageSize:pageSize];
        NSLog(@"getMockData page resp:%lu, pagSize:%lu data:%lu", page, (unsigned long)pageSize, ret.count);
        
        if (page == 1) {
            self.data = ret;
        } else {
            self.data = [self.data arrayByAddingObjectsFromArray:ret];
        }
        
        if (success) {
            success(ret);
        }
    });
}

@end
