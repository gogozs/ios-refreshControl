//
//  SZTableViewController.m
//  SZRefreshControl
//
//  Created by songzhou on 2018/3/6.
//  Copyright © 2018年 Song Zhou. All rights reserved.
//

#import "SZTableViewController.h"
#import "SZRefreshControl.h"
#import "MockStore.h"

@interface SZTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) SZRefreshUITableViewController *tableViewController;

@property (nonatomic) MockStore *store;

@property (nonatomic) NSUInteger refreshCount;

@end

@implementation SZTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _store = [MockStore new];

    
    _tableViewController = [SZRefreshUITableViewController new];
    [self addChildViewController:_tableViewController];
    [self.view addSubview:_tableViewController.view];
    self.tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint
     activateConstraints:
     @[
       [self.tableViewController.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
       [self.tableViewController.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
       [self.tableViewController.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
       [self.tableViewController.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
       ]];
    

    self.tableViewController.tableView.dataSource = self;
    self.tableViewController.tableView.delegate = self;
    
    [self.tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    

    [self.tableViewController.refreshHeaderControl addTarget:self action:@selector(headerRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableViewController.refreshFooterControl addTarget:self action:@selector(footerRefresh:) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:MockStoreDidGetDataNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      __strong typeof(wself) self = wself;
                                                      
                                                      self.refreshCount += 1;
                                                      NSLog(@"refreshCount:%ld", self.refreshCount);
                                                      if (self.refreshCount == 7) {
                                                          [self.tableViewController.refreshFooterControl finishRefresh];
                                                      } else {
                                                          [self.tableViewController.refreshFooterControl stopRefresh];
                                                      }

                                                      [self.tableViewController.refreshHeaderControl stopRefresh];
                                                      [self.tableViewController.tableView reloadData];
                                                  }];
}

- (void)headerRefresh:(SZRefreshHeader *)sender {
    self.store.data = nil;
    self.refreshCount = 0;
    [self.store getMockDataWithResponseTime:2 success:NULL];
}

- (void)footerRefresh:(SZRefreshFooter *)sender {
    NSLog(@"footer refreshing...");
    [self.store getMockDataWithResponseTime:0.2 success:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableViewController.refreshHeaderControl startRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.store.data.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *data = self.store.data[indexPath.row];
    cell.textLabel.text = data;
    
    return cell;
}

@end
