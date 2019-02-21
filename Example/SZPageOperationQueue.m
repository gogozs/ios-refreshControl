//
//  SZPageOperationQueue.m
//  SZRefreshControl
//
//  Created by songzhou on 2019/2/20.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "SZPageOperationQueue.h"


#define SZ_PAGE_LOG_ENABLE 1

#if SZ_PAGE_LOG_ENABLE == 1
#define SZPageOperationQueueLog(format, ...) NSLog(format, ##__VA_ARGS__);
#else
#define SZPageOperationQueueLog(format, ...)
#endif

@implementation SZPageOperation

+ (instancetype)async:(SZPageOperationAsyncWorkBlock)work {
    SZPageOperation *operation = [SZPageOperation new];
    operation.work = work;
    
    return operation;
}

@end

@interface SZPageOperationQueue () <SZPageOperationDelegate>

@property (nonatomic) NSMutableArray *operations;

@property (nonatomic) NSUInteger initialPage;
@property (nonatomic, readwrite) NSUInteger page;
@property (nonatomic, readwrite) NSUInteger pageSize;

@end

@implementation SZPageOperationQueue

+ (instancetype)defaultQueue {
    return [[self alloc] init];
}

+ (instancetype)queueWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize {
    return [[self alloc] initWithPage:page pageSize:pageSize];
}

- (instancetype)init {
    return [self initWithPage:1 pageSize:20];
}

- (instancetype)initWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize {
    self = [super init];
    
    if (self) {
        _operations = [NSMutableArray arrayWithCapacity:1];
        _initialPage = page;
        _page = page;
        _pageSize = pageSize;
        _lastPage = NO;
    }
    
    return self;
}

#pragma mark - Setter
- (void)setPage:(NSUInteger)page {
    _page = page;
}

#pragma mark - Public
- (BOOL)addPageOperation:(SZPageOperation *)operation {
    if (_operations.count) {
        SZPageOperationQueueLog(@"[PageQueue] - current opeation is running, discard new operation:%@", operation);
        return NO;
    }
    

    [self _addPageOperation:operation];
    
    return YES;
}

- (void)resetPage{
    self.page = self.initialPage;
    
    SZPageOperationQueueLog(@"[PageQueue] - reset page:%lu", self.page);
}

- (void)updatePage {
    self.page += 1;
    
    SZPageOperationQueueLog(@"[PageQueue] - update page:%lu", self.page);
}

#pragma mark - Private
- (void)_addPageOperation:(SZPageOperation *)operation {
    SZPageOperationQueueLog(@"[PageQueue] - excuting operation:%@", operation);
    [_operations addObject:operation];
    
    operation.delegate = self;
    
    operation.work(operation);
}

- (BOOL)_removeOperation {
    SZPageOperation *operation;
    if (self.operations.count) {
        operation = self.operations[0];
        [self.operations removeObjectAtIndex:0];
    }
    
    SZPageOperationQueueLog(@"[PageQueue] - remove operation:%@", operation);
    
    return operation != nil;
}

#pragma mark - SZPageOperationDelegate
- (void)pageOperation:(SZPageOperation *)operation fulfillWithValue:(id)value {
    [self _removeOperation];

}

- (void)pageOperation:(SZPageOperation *)operation rejectWithError:(NSError *)error {
    [self _removeOperation];
}

@end
