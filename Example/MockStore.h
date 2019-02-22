//
//  MockStore.h
//  SZRefreshControl
//
//  Created by songzhou on 2018/8/12.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SZPageOperationQueue.h"
#import "SZTableViewDiff.h"

extern NSString *const MockStoreDidGetDataNotification;
extern NSString *const MockStorePagingFinishedKey;

@interface MockStore : NSObject

@property (nonatomic, copy) NSArray<NSString *> *data;
@property (nonatomic) SZTableViewDiff *tableViewDiff;

@property (nonatomic, copy) NSArray *pageData;

@property (nonatomic) dispatch_queue_t pagingQueue;

- (void)getMockDataWithResponseTime:(NSInteger)time success:(void(^)(NSArray<NSString *> *))success;


- (void)getMockDataWithResponseTime:(NSInteger)time
                               page:(NSUInteger)page
                           pageSize:(NSUInteger)pageSize
                            success:(void(^)(NSArray<NSString *> *))success;

- (void)getMockDataWithResponseTime:(NSInteger)time
                               page:(SZPageOperationQueue *)pageQueue
                            success:(void(^)(NSArray<NSString *> *))success;

@end
