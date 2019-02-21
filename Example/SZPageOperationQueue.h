//
//  SZPageOperationQueue.h
//  SZRefreshControl
//
//  Created by songzhou on 2019/2/20.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SZPageOperation;
typedef void(^SZPageOperationAsyncWorkBlock)(SZPageOperation *operation);


@protocol SZPageOperationDelegate <NSObject>

@required
- (void)pageOperation:(SZPageOperation *)operation fulfillWithValue:(nullable id)value;
- (void)pageOperation:(SZPageOperation *)operation rejectWithError:(NSError *)error;

@end

@interface SZPageOperation : NSObject

@property (nonatomic, copy) SZPageOperationAsyncWorkBlock work;
@property (nonatomic, weak) id<SZPageOperationDelegate> delegate;

+ (instancetype)async:(SZPageOperationAsyncWorkBlock)work;

@end

/// capacity is 1
@interface SZPageOperationQueue : NSObject

@property (nonatomic, readonly) NSUInteger page;
@property (nonatomic, readonly) NSUInteger pageSize;

@property (nonatomic, getter=isLastPage) BOOL lastPage;

+ (instancetype)queueWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize;
+ (instancetype)defaultQueue;
- (instancetype)initWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize NS_DESIGNATED_INITIALIZER;

- (BOOL)addPageOperation:(SZPageOperation *)operation;


- (void)resetPage;
- (void)updatePage;

@end

NS_ASSUME_NONNULL_END
