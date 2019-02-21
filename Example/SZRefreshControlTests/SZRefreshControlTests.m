//
//  SZRefreshControlTests.m
//  SZRefreshControlTests
//
//  Created by songzhou on 2019/2/20.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MockStore.h"
#import "SZPageOperationQueue.h"

@interface SZRefreshControlTests : XCTestCase

@property (nonatomic) MockStore *store;
@property (nonatomic) NSUInteger page;

@property (nonatomic) XCTestExpectation *pagingExpectation;
@property (nonatomic) XCTestExpectation *asyncPagingExpectation;
@property (nonatomic) XCTestExpectation *asyncPagingOperationExpectation;

@property (nonatomic) NSString *paging;
@property (nonatomic) NSString *asyncPaging;

@property (nonatomic) SZPageOperationQueue *pagingOpeartionQueue;

@end

@implementation SZRefreshControlTests

- (void)setUp {
    _store = [MockStore new];
    _page = 1;
    _paging = @"paging";
    _asyncPaging = @"async paging";

    _pagingOpeartionQueue = [SZPageOperationQueue defaultQueue];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handlePagingNotification:) name:MockStoreDidGetDataNotification object:self.paging];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleAsyncPagingNotification:) name:MockStoreDidGetDataNotification object:self.asyncPaging];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleAsyncPagingOperationNotification:) name:MockStoreDidGetDataNotification object:self.asyncPagingOperationExpectation];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPaging {
    _pagingExpectation = [self expectationWithDescription:@"paging"];
    
    [self.store getMockDataWithResponseTime:1
                                       page:self.page
                                   pageSize:20
                                    success:NULL];

    [self waitForExpectationsWithTimeout:1 handler:NULL];
}

- (void)test:(NSTimeInterval)interval {
    [NSThread sleepForTimeInterval:interval];
    NSLog(@"%lf", interval);
}

/// one request at a time
- (void)testAsyncPaging {
    _asyncPagingExpectation = [self expectationWithDescription:@"async paging"];
    NSLog(@"started");

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(self.store.pagingQueue, ^{
        [self.store getMockDataWithResponseTime:2
                                           page:self.page
                                       pageSize:20
                                        success:^(NSArray<NSString *> * data) {
                                            dispatch_semaphore_signal(sema);
                                            [[NSNotificationCenter defaultCenter] postNotificationName:MockStoreDidGetDataNotification object:self.asyncPaging userInfo:nil];
                                        }];
    });

    dispatch_async(self.store.pagingQueue, ^{
        self.page += 1;
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        [self.store getMockDataWithResponseTime:1
                                           page:self.page
                                       pageSize:20
                                        success:^(NSArray<NSString *> * data) {
                                            dispatch_semaphore_signal(sema);
                                            [[NSNotificationCenter defaultCenter] postNotificationName:MockStoreDidGetDataNotification object:self.asyncPaging userInfo:nil];
                                        }];
    });

    [self waitForExpectationsWithTimeout:4 handler:NULL];
}

- (SZPageOperation *)_pagingOperationWithTime:(NSTimeInterval)timeInterval {
    return
    [SZPageOperation async:^(SZPageOperation * _Nonnull operation) {
        [self.store getMockDataWithResponseTime:timeInterval
                                           page:self.pagingOpeartionQueue
                                        success:^(NSArray<NSString *> * data) {
                                            [operation.delegate pageOperation:operation fulfillWithValue:data];
                                            self.pagingOpeartionQueue.lastPage = data.count == 0;
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:MockStoreDidGetDataNotification
                                                                                                object:self.asyncPagingOperationExpectation
                                                                                              userInfo:nil];

                                        }];
    }];
}

- (void)testPagingOperation {
    _asyncPagingOperationExpectation = [self expectationWithDescription:@"_asyncPagingOperationExpectation"];
    
    
    SZPageOperation *operation1 = [self _pagingOperationWithTime:2];
    
    SZPageOperation *operation2 = [self _pagingOperationWithTime:1];
    
    [self.pagingOpeartionQueue addPageOperation:operation1];
    [self.pagingOpeartionQueue addPageOperation:operation2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self.pagingOpeartionQueue addPageOperation:operation2];
    });
    
    [self waitForExpectationsWithTimeout:6 handler:NULL];
}

#pragma mark - Notification
- (void)handlePagingNotification:(NSNotification *)note {
    XCTAssert(self.store.data.count == 20);
    XCTAssert(self.store.pageData.count == 3);
    
    [self.pagingExpectation fulfill];
}

- (void)handleAsyncPagingNotification:(NSNotification *)note {
    NSLog(@"getMockData notification page:%lu, data:%@", self.page, self.store.data);
    
    if (self.store.data.count == 2*20) {
        [self.asyncPagingExpectation fulfill];
    }
    
}

- (void)handleAsyncPagingOperationNotification:(NSNotification *)note {
    NSLog(@"getMockData notification page:%lu, data:%@", self.pagingOpeartionQueue.page, self.store.data);
    
    if (self.pagingOpeartionQueue.isLastPage) {
        
    } else {
        [self.pagingOpeartionQueue updatePage];
        
        if (self.store.data.count == 2*20) {
            [self.asyncPagingOperationExpectation fulfill];
        }
    }
   

}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
