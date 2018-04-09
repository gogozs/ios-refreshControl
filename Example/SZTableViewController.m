//
//  SZTableViewController.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/6.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "SZTableViewController.h"
#import "SZRefreshControl.h"

@interface SZTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) SZTableView *view;

@property (nonatomic) NSArray *dataSource;

@property (nonatomic) BOOL append;

@end

@implementation SZTableViewController

@dynamic view;

- (void)loadView {
    self.view = [SZTableView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _append = NO;
    
    NSMutableArray *mdataSource = @[].mutableCopy;
    for (int i = 0; i < 20; i++) {
        [mdataSource addObject:@(i)];
    }
    _dataSource = mdataSource;
    
    self.view.dataSource = self;
    self.view.delegate = self;
    
    [self.view registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    __weak typeof(self) wself = self;
    self.view.refreshHeader = [SZRefreshHeader refreshHeaderWithBlock:^{
        __strong typeof(self) sself = wself;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sself.view.refreshHeader stopRefresh];
        });

    }];
    
    self.view.refreshFooter = [SZRefreshFooter refreshFooterWithBlock:^{
        NSLog(@"footer refreshing...");
        __strong typeof(self) sself = wself;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view.refreshFooter stopRefresh];
            if (!_append) {
                _append = YES;
                [self _appendData];
//                [sself.view.refreshFooter finishRefresh];
                [sself.view reloadData];
            } else {

            }
            


        });
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    CGFloat w = CGRectGetWidth(self.view.bounds);
//    CGFloat h = CGRectGetHeight(self.view.bounds);
    
//    self.view.contentSize = CGSizeMake(w, h);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_appendData {
    NSMutableArray *mdataSource = @[].mutableCopy;
    for (int i = 0; i < 10; i++) {
        [mdataSource addObject:@(i)];
    }
    
    _dataSource = [_dataSource arrayByAddingObjectsFromArray:mdataSource];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSNumber *data = _dataSource[indexPath.row];
    cell.textLabel.text = data.stringValue;
    
    return cell;
}

@end
