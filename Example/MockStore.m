//
//  MockStore.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/8/12.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "MockStore.h"

NSString *const MockStoreDidGetDataNotification = @"MockStoreDidGetDataNotification";

@implementation MockStore

- (void)getMockDataWithResponseTime:(NSInteger)time success:(void(^)(NSArray<NSString *> *))success {
    NSLog(@"%s", __func__);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray<NSString *> *ret = [NSMutableArray arrayWithCapacity:20];
 
        if (!self.data) {
            for (int i = 0; i < 20; i++) {
                [ret addObject:@(i).stringValue];
            }
            self.data = [ret copy];
        } else {
            if (self.data.count > 40) {
                NSLog(@"request finished");
            } else {
                for (int i = (int)self.data.count; i < self.data.count + 20; i++) {
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

@end
