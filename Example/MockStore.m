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
    }
    return self;
}

#pragma mark - Setter
- (void)setData:(NSArray<NSString *> *)data {
    self.tableViewDiff = [SZTableViewDiff diffWithOrigin:_data new:data];
    
    _data = data;
}

#pragma mark -
- (void)_pagingWithPageSize:(NSUInteger)pageSize {
    NSUInteger pages = ceilf((float)self.total/pageSize);
    
    NSUInteger total = self.total;
    NSMutableArray *pageData = [NSMutableArray arrayWithCapacity:pages];
    NSUInteger data = 0;
    for (int i = 0; i < pages; i++) {
        NSUInteger currentSize = total < pageSize ? total : pageSize;
        NSMutableArray *currentData = [NSMutableArray arrayWithCapacity:currentSize];
        for (int j = 0; j < currentSize; j++) {
            [currentData addObject:[@(++data) stringValue]];
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
                               page:(SZPagingBehaviour *)pageQueue
                            success:(void(^)(NSArray<NSString *> *))success {
    NSUInteger page = pageQueue.page;
    NSUInteger pageSize = pageQueue.pageSize;
    
    NSLog(@"getMockData page request:%lu, pagSize:%lu", page, (unsigned long)pageSize);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *ret = [self dataWithPage:page-1 pageSize:pageSize];

        
        if (page == pageQueue.initialPage) {
            self.data = ret;
        } else {
            self.data = [self.data arrayByAddingObjectsFromArray:ret];
        }
        
        NSLog(@"getMockData page resp:%lu, pagSize:%lu ret:%lu total:%lu", page, (unsigned long)pageSize, ret.count, self.data.count);
        if (success) {
            success(ret);
        }
    });
}

@end
