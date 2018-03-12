//
//  ViewController.m
//  SZRefreshControl
//
//  Created by Song Zhou on 17/12/2017.
//  Copyright © 2017 Song Zhou. All rights reserved.
//

#import "SZViewController.h"
#import "SZScrollViewController.h"
#import "SZTableViewController.h"
#import "SZNativeRefreshControlViewController.h"

static NSString *const PLAIN_CELL_IDENTIFIER = @"PLAIN_CELL_IDENTIFIER";
@interface SZViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *view;

@property (nonatomic) NSArray *dataSource;

@end

@implementation SZViewController
@dynamic view;

- (void)loadView {
    self.view = [UITableView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.view.delegate = self;
    [self.view registerClass:[UITableViewCell class] forCellReuseIdentifier:PLAIN_CELL_IDENTIFIER];
    self.view.dataSource = self;
    self.view.delegate = self;
    
    _dataSource = @[
                    @"scroll view",
                    @"table view",
                    @"native refresh control",
                    ];
    
    [self.view reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLAIN_CELL_IDENTIFIER];
    
    cell.textLabel.text = _dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[SZScrollViewController new] animated:YES];
        return;
    }
    
    if (indexPath.row == 1) {
        [self.navigationController pushViewController:[SZTableViewController new] animated:YES];
        return;
    }
    
    if (indexPath.row == 2) {
        [self.navigationController pushViewController:[SZNativeRefreshControlViewController new] animated:YES];
        return;
    }
}
@end
