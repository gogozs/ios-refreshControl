//
//  MockStore.h
//  SZRefreshControl
//
//  Created by songzhou on 2018/8/12.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MockStoreDidGetDataNotification;

@interface MockStore : NSObject

@property (nonatomic, copy) NSArray<NSString *> *data;

- (void)getMockDataWithResponseTime:(NSInteger)time success:(void(^)(NSArray<NSString *> *))success;

@end
