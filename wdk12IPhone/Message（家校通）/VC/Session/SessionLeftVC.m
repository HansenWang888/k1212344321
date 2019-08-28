//
//  SessionLeftVC.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/19.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "SessionLeftVC.h"
#import "SessionTableView.h"
#import "ChatVIewController.h"
#import "sessionCell.h"
#import <Masonry.h>
#import "SubcripeSessionVC.h"
@interface SessionLeftVC ()<SessionTableViewDelegta>
@property (strong, nonatomic) SessionTableView *tableView;
@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation SessionLeftVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title = @"消息";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:IMLocalizedString(@"消息", nil) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn sizeToFit];
    btn.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = COLOR_Creat(50, 58, 67, 1);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localPrepare) name:DDNotificationLocalPrepared object:nil];
    self.tableView.backgroundColor = [UIColor colorWithRed:49/255.0 green:58/255.0 blue:67/255.0 alpha:1];
    self.tableView = [SessionTableView new];
    self.view.backgroundColor = COLOR_Creat(50, 58, 67, 1);
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);

        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.view).offset(10);
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.Sessiondelegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(localPrepared) name:DDNotificationLocalPrepared object:nil];

}
- (void)localPrepared {
    [_tableView reloadData];
}
- (void)SessionTouched:(SessionCell *)sessioncell {
    ChatViewController *chatVC = [ChatViewController initWithSessionEntity:sessioncell.sessionEntity];
    [self.navigationController pushViewController:chatVC animated:YES];
}
- (void)SubscribeTouched {
    SubcripeSessionVC *subcripeVC = [SubcripeSessionVC new];
    [self.navigationController pushViewController:subcripeVC animated:YES];
}
- (void)localPrepare {
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIToolbar *)toolBar {
    if (!_toolBar ) {
        _toolBar = [[UIToolbar alloc] init];
        _toolBar.items = @[[[UIBarButtonItem alloc]initWithTitle:IMLocalizedString(@"消息", nil) style:0 target:0 action:0]];
    }
    return _toolBar;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
