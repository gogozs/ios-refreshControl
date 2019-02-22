//
//  SZTableViewDiff.h
//  SZRefreshControl
//
//  Created by songzhou on 2019/2/22.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SZTableViewDiffReason) {
    SZTableViewDiffReasonReload = -1,
    SZTableViewDiffReasonSame,
    SZTableViewDiffReasonAdd,
    SZTableViewDiffReasonRemove,
};

@class SZTableViewDiff;

// one section
extern void SZTableViewDiffUpdate(UITableView *tableView, SZTableViewDiff *diff);

@interface SZTableViewDiff : NSObject

@property SZTableViewDiffReason reason;
@property (nullable, nonatomic, copy) NSArray<NSNumber *> *indexs;

+ (instancetype)diffWithOrigin:(NSArray *)origin new:(NSArray *)newData;

@end

NS_ASSUME_NONNULL_END
