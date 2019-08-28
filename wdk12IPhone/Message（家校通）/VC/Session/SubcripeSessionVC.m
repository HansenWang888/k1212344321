//
//  SubcripeSessionVC.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/30.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "SubcripeSessionVC.h"
#import "SessionTableView.h"
#import <Masonry.h>
#import "ChatVIewController.h"
#import "sessionCell.h"
#import "ViewSetUniversal.h"
@interface SubcripeSessionVC ()<SessionTableViewDelegta>
@property (nonatomic, strong) SessionTableView *subcripeTabV;

@end

@implementation SubcripeSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = IMLocalizedString(@"公众号消息", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.subcripeTabV = [[SessionTableView alloc] initWithSessionTableViewType:SessionTableViewTypeSubscribe];
    self.subcripeTabV.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.view addSubview:self.subcripeTabV];
    [self.subcripeTabV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.right.equalTo(self.view).offset(-5);
        make.top.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view);
    }];
    self.subcripeTabV.Sessiondelegate = self;
    self.subcripeTabV.backgroundColor = [UIColor clearColor];
}
- (void)SessionTouched:(SessionCell *)sessioncell {
    ChatViewController *chatVC = [ChatViewController initWithSessionEntity:sessioncell.sessionEntity];
    [self.navigationController pushViewController:chatVC animated:YES];
}
- (SessionTableView *)subcripeTabV {
    if (!_subcripeTabV) {
        _subcripeTabV = [[SessionTableView alloc] init];
    }
    return _subcripeTabV;
}
@end
