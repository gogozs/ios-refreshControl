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

#import "SZPageOperationQueue.h"
#import "SZTableViewDiff.h"

static const NSUInteger page_size = 10;

@interface SZTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) SZRefreshUITableViewController *tableViewController;

@property (nonatomic) MockStore *store;

@property (nonatomic) SZPageOperationQueue *pagingQueue;

@end

@implementation SZTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _store = [MockStore new];
    _pagingQueue = [SZPageOperationQueue queueWithPage:1 pageSize:page_size];
    
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
    
    [self.tableViewController.pullToRefreshController.refershControl addTarget:self action:@selector(headerRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableViewController.footerPullToRefreshController.refershControl addTarget:self action:@selector(footerRefresh:) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:MockStoreDidGetDataNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      __strong typeof(wself) self = wself;
// will crash if header stopRefresh before tableView reload
                                                      SZTableViewDiffUpdate(self.tableViewController.tableView, self.store.tableViewDiff);
                                                      
                                                      if (self.pagingQueue.isLastPage) {
                                                          [self.tableViewController.footerPullToRefreshController endRefreshing];
                                                      } else {
                                                          [self.pagingQueue updatePage];
                                                          [self.tableViewController.footerPullToRefreshController endRefreshing];
                                                      }

                                                      [self.tableViewController.pullToRefreshController endRefreshing];
                                                  
                                                  }];
    
}

- (SZPageOperation *)pageOperationWithTimeInterval:(NSTimeInterval)timeInterval {
    return
    [SZPageOperation async:^(SZPageOperation * _Nonnull operation) {
        [self.store getMockDataWithResponseTime:timeInterval
                                           page:self.pagingQueue
                                        success:^(NSArray<NSString *> * data) {
                                            [operation.delegate pageOperation:operation fulfillWithValue:data];
                                            self.pagingQueue.lastPage = data.count == 0;

                                            [[NSNotificationCenter defaultCenter] postNotificationName:MockStoreDidGetDataNotification
                                                                                                object:self.pagingQueue
                                                                                              userInfo:nil];
                                        }];
    }];
}

- (void)headerRefresh:(SZRefreshHeader *)sender {
    NSLog(@"header refreshing...");
    [self.pagingQueue resetPage];

    [self.pagingQueue addPageOperation:[self pageOperationWithTimeInterval:2]];
}

- (void)footerRefresh:(SZRefreshFooter *)sender {
    NSLog(@"footer refreshing...");
    [self.pagingQueue addPageOperation:[self pageOperationWithTimeInterval:2]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableViewController.pullToRefreshController beginRefreshing];
    [self.pagingQueue resetPage];
    [self.pagingQueue addPageOperation:[self pageOperationWithTimeInterval:2]];
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
