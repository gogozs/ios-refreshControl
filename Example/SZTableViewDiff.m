//
//  SZTableViewDiff.m
//  SZRefreshControl
//
//  Created by songzhou on 2019/2/22.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "SZTableViewDiff.h"

@implementation SZTableViewDiff

+ (instancetype)diffWithOrigin:(NSArray *)origin new:(NSArray *)newData {
    NSMutableSet *originalSet = [NSMutableSet setWithArray:origin];
    NSMutableSet *newSet = [NSMutableSet setWithArray:newData];
    
    SZTableViewDiff *diff = [SZTableViewDiff new];
    
    SZTableViewDiffReason reason = SZTableViewDiffReasonSame;
    NSMutableArray<NSNumber *> *indexes;
    
    if ([originalSet isEqualToSet:newSet]) { // equal
        reason = SZTableViewDiffReasonSame;
    } else if ([originalSet isSubsetOfSet:newSet]) { // append
        [newSet minusSet:originalSet];
        
        indexes = [NSMutableArray arrayWithCapacity:newSet.count];
        [newData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([newSet containsObject:obj]) {
                [indexes addObject:@(idx)];
            }
        }];
        
        
        reason = SZTableViewDiffReasonAdd;
    } else if ([newSet isSubsetOfSet:originalSet]) { // remove
        [originalSet minusSet:newSet];
        indexes = [NSMutableArray arrayWithCapacity:originalSet.count];
        
        [origin enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([originalSet containsObject:obj]) {
                [indexes addObject:@(idx)];
            }
        }];
        
        reason = SZTableViewDiffReasonRemove;
    } else {
        reason = SZTableViewDiffReasonReload;
    }
    
    diff.reason = reason;
    diff.indexs = indexes;
    
    return diff;
}
@end

void SZTableViewDiffUpdate(UITableView *tableView, SZTableViewDiff *diff) {
    switch (diff.reason) {
        case SZTableViewDiffReasonAdd: {
            // no section or section has no data, just reload
            if (tableView.numberOfSections == 0 ||
                [tableView numberOfRowsInSection:0] == 0) {
                [tableView reloadData];
            } else {
                [tableView beginUpdates];
                NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:diff.indexs.count];
                [diff.indexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:obj.integerValue inSection:0]];
                }];
                
                [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
            }
            
            break;
        }
            
        case SZTableViewDiffReasonRemove: {
            [tableView beginUpdates];
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:diff.indexs.count];
            [diff.indexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:obj.integerValue inSection:0]];
            }];
            
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
            [tableView endUpdates];
            break;
        }
            
        case SZTableViewDiffReasonSame: {
            break;
        }
        case SZTableViewDiffReasonReload: {
            [tableView reloadData];
            break;
        }
    }
}
