//
//  SZInfiniteTableViewController.m
//  SZRefreshControl
//
//  Created by songzhou on 2019/2/28.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "SZInfiniteTableViewController.h"
#import "SZRefreshControl.h"

#import "MockStore.h"
#import "SZPagingBehaviour.h"

@interface SZInfiniteTableViewController ()

@property (nonatomic) MockStore *store;
@property (nonatomic) SZPagingBehaviour *pagingBehaviour;


@property (nonatomic) SZPullToRefreshController *pullToRefreshController;
@property (nonatomic) SZInfiniteRefreshController *footerRefreshController;

@end

@implementation SZInfiniteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _store = [MockStore new];
    _pagingBehaviour = [SZPagingBehaviour queueWithPage:1 pageSize:10];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleNotification:) name:MockStoreDidGetDataNotification object:self.pagingBehaviour];
   
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _pullToRefreshController = [[SZPullToRefreshController alloc] init];
    [_pullToRefreshController addToScrollView:self.tableView];

    _footerRefreshController = [[SZInfiniteRefreshController alloc] init];
    [_footerRefreshController addToScrollView:self.tableView];
    
    [self.pullToRefreshController.refershControl addTarget:self action:@selector(headerRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.footerRefreshController.refershControl addTarget:self action:@selector(footerRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.pullToRefreshController beginRefreshing];
}

#pragma mark - Notification
- (void)handleNotification:(NSNotification *)note {
    SZTableViewDiffUpdate(self.tableView, self.store.tableViewDiff);
    
    [self.pullToRefreshController endRefreshing];
    
    if ([self.pagingBehaviour isLastPage]) {
        [self.footerRefreshController finishRefreshing];
    } else {
        [self.pagingBehaviour updatePage];
        [self.footerRefreshController endRefreshing];
    }
}

#pragma mark - Action
- (void)headerRefresh:(SZPullToRefreshControl *)sender {
    NSLog(@"header refreshing...");
    [self.pagingBehaviour resetPage];
    
    [self pageRequestWithTimeInterval:2];
}

- (void)footerRefresh:(SZRefreshFooter *)sender {
    [self pageRequestWithTimeInterval:0.2];
}

#pragma mark - Privaite
- (void)pageRequestWithTimeInterval:(NSTimeInterval)timeInterval {
    [self.store getMockDataWithResponseTime:timeInterval
                                       page:self.pagingBehaviour
                                    success:^(NSArray<NSString *> * data) {
                                        self.pagingBehaviour.lastPage = data.count == 0;
                                        
                                        [[NSNotificationCenter defaultCenter] postNotificationName:MockStoreDidGetDataNotification
                                                                                            object:self.pagingBehaviour
                                                                                          userInfo:nil];
                                    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.store.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *data = self.store.data[indexPath.row];
    cell.textLabel.text = data;
    
    return cell;
}

@end
