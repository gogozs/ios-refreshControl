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

@interface SZTableViewControllerContainer: UIView

@property (nonatomic) SZTableView *tableView;

@end

@implementation SZTableViewControllerContainer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[SZTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint
         activateConstraints:
         @[
           [_tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
           [_tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
           [_tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
           [_tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
           ]];
    }
    return self;
}

@end

@interface SZTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) SZTableViewControllerContainer *view;

@property (nonatomic) MockStore *store;

@end

@implementation SZTableViewController

@dynamic view;

- (void)loadView {
    self.view = [SZTableViewControllerContainer new];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _store = [MockStore new];
    
    self.view.tableView.dataSource = self;
    self.view.tableView.delegate = self;
    
    [self.view.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    __weak typeof(self) wself = self;
  
    self.view.tableView.refreshFooter = [SZRefreshFooter refreshFooterWithBlock:^{
        NSLog(@"footer refreshing...");
        __strong typeof(wself) self = wself;
        [self.store getMockDataWithResponseTime:0.2 success:NULL];
    }];
    

    [[NSNotificationCenter defaultCenter] addObserverForName:MockStoreDidGetDataNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      __strong typeof(wself) self = wself;
                                                      
                                                      [self.view.tableView.refreshFooter deferStopRefresh];
                                                      [self.view.tableView reloadData];
                                                  }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.store getMockDataWithResponseTime:0.2 success:NULL];
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
