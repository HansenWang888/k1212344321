//
//  InteractionViewController.m
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "InteractionViewController.h"
#import "InteractionTableView.h"
#import "interactionDetailViewController.h"
#import "QuestionViewController.h"


@interface InteractionViewController () {
    InteractionTableView *tableView;
}

///  tableView
@property (nonatomic, strong) InteractionTableView *interTableView;

@end

@implementation InteractionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViewToView];
    //接收tableView的push通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewPush:) name:@"interctionPush" object:nil];
    //添加nav右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(clickNavRightBtn)];
}

- (void)addSubViewToView {
    self.view.backgroundColor = [UIColor whiteColor];
    //添加选择条
    UISegmentedControl * segment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All questions", nil),NSLocalizedString(@"My question", nil)]];
    segment.selectedSegmentIndex = 0;
    segment.tintColor = [UIColor colorWithRed:57/255.0 green:235/255.0 blue:207/255.0 alpha:1.0];
    segment.frame = CGRectMake(0, 0, 250, 35);
    segment.center = CGPointMake(self.view.center.x, 78 + 10);
    [segment addTarget:self action:@selector(segmentedControlClick:) forControlEvents:UIControlEventValueChanged];
    self.segment = segment;
    [self.view addSubview:segment];
    
    tableView = [[InteractionTableView alloc] init];
    self.interTableView = tableView;
    tableView.questionType = 1;
    tableView.frame = CGRectMake(0, CGRectGetMaxY(segment.frame) + 5, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(segment.frame));
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
}

- (void)clickNavRightBtn {
    //点击nav右边按钮
    QuestionViewController * questionVc = [[QuestionViewController alloc]init];
    [questionVc setHidesBottomBarWhenPushed:true];
    [self.navigationController pushViewController:questionVc animated:YES];
}

//选择监听 1所有问题 2我的提问
- (void)segmentedControlClick:(UISegmentedControl *)segmentCtl{
    tableView.questionType = ((segmentCtl.selectedSegmentIndex == 0) ? 1 : 2);
}

- (void)tableViewPush:(NSNotification *)selectedInfo {
    interactionDetailViewController * interactionVc = [[interactionDetailViewController alloc]init];
    interactionVc.infoDic = selectedInfo.object;
    [interactionVc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:interactionVc animated:YES];
    
}

@end
