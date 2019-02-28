//
//  SZPageOperationQueue.m
//  SZRefreshControl
//
//  Created by songzhou on 2019/2/20.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "SZPagingBehaviour.h"


#define SZ_PAGE_LOG_ENABLE 0

#if SZ_PAGE_LOG_ENABLE == 1
#define SZPageBehaviourLog(format, ...) NSLog(format, ##__VA_ARGS__);
#else
#define SZPageBehaviourLog(format, ...)
#endif

static const NSUInteger kDefaultInitalPage = 1;
static const NSUInteger kDefaultPageSize = 20;

@interface SZPagingBehaviour ()

@property (nonatomic, readwrite) NSUInteger initialPage;
@property (nonatomic, readwrite) NSUInteger page;
@property (nonatomic, readwrite) NSUInteger pageSize;

@end

@implementation SZPagingBehaviour

+ (instancetype)defaultQueue {
    return [[self alloc] init];
}

+ (instancetype)queueWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize {
    return [[self alloc] initWithPage:page pageSize:pageSize];
}

- (instancetype)init {
    return [self initWithPage:kDefaultInitalPage pageSize:kDefaultPageSize];
}

- (instancetype)initWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize {
    self = [super init];
    
    if (self) {
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
- (void)resetPage{
    self.page = self.initialPage;
    
    SZPageBehaviourLog(@"[PageBehaviour] - reset page:%lu", self.page);
}

- (void)updatePage {
    self.page += 1;
    
    SZPageBehaviourLog(@"[PageBehaviour] - update page:%lu", self.page);
}

@end
