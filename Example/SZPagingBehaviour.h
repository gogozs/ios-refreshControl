//
//  SZPageOperationQueue.h
//  SZRefreshControl
//
//  Created by songzhou on 2019/2/20.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SZPagingBehaviour : NSObject

@property (nonatomic, readonly) NSUInteger initialPage;
@property (nonatomic, readonly) NSUInteger page;
@property (nonatomic, readonly) NSUInteger pageSize;

@property (nonatomic, getter=isLastPage) BOOL lastPage;

+ (instancetype)queueWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize;
+ (instancetype)defaultQueue;
- (instancetype)initWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize NS_DESIGNATED_INITIALIZER;

- (void)resetPage;
- (void)updatePage;

@end

NS_ASSUME_NONNULL_END
