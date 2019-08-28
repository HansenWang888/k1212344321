//
//  HWAddSmallGroupViewController.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWAddSmallGroupViewController.h"
#import "HWAddSmallGroupViewController.h"
#import "HWCreatTaskViewController.h"
#import "SmallGroupStudentModel.h"
#import "HWAddClassViewModel.h"
#import "StudentModel.h"
#import "ClassModel.h"

@interface HWAddSmallGroupViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
///  右侧阴影view
@property (nonatomic, strong) UIView *rightView;
///  确定按钮
@property (nonatomic, strong) UIButton *trueButton;

@property (nonatomic, strong) NSMutableDictionary *dictM;

@end

@implementation HWAddSmallGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initView];
    [self loadData];
}

- (void)initNav {
    self.trueButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"确定", nil) titleColor:[UIColor hex:0x5C5C5C alpha:1.0] backgroundColor:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.trueButton];
    [self.trueButton addTarget:self action:@selector(trueSelectStudentAction) forControlEvents:UIControlEventTouchUpInside];
    self.trueButton.enabled = false;
    [self.trueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    titleLabel.bounds = CGRectMake(0, 0, 100, 30);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    titleLabel.text = self.addType ? NSLocalizedString(@"请选择您要添加的小组", nil) : NSLocalizedString(@"请选择需要添加的个人", nil);
    
    self.tableView = [UITableView tableViewWithSuperView:self.view dataSource:self backgroundColor:[UIColor whiteColor] separatorStyle:UITableViewCellSeparatorStyleSingleLine registerCell:[UITableViewCell class] cellIdentifier:@"UITableViewCell"];
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [UIView new];
    
    self.rightView = [UIView new];
    [self.view addSubview:self.rightView];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.view);
        make.width.offset(1);
    }];
    self.rightView.backgroundColor = [UIColor hex:0x000000 alpha:0.1];
    [self.rightView getShadowOnLeft];
}

#pragma mark - tableView dataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    UISwitch *sw = [UISwitch new];
    sw.tag = indexPath.row;
    [sw addTarget:self action:@selector(selectClassWith:) forControlEvents:UIControlEventValueChanged];

    if (self.addType) {
        SmallGroupStudentModel *obj = self.dataSource[indexPath.row];
        cell.textLabel.text = obj.smallGroupName;
        sw.on = obj.isSelect;
    } else {
        StudentModel *obj = self.dataSource[indexPath.row];
        cell.textLabel.text = obj.name;
        sw.on = obj.isSelect;
    }
    cell.accessoryView = sw;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

///  选择小组或个人
- (void)selectClassWith:(UISwitch *)sender {
    if (self.addType) {
        SmallGroupStudentModel *model = self.dataSource[sender.tag];
        model.isSelect = sender.on;
        if (sender.on) {
            self.dictM[model.id] = model;
        } else {
            [self.dictM removeObjectForKey:model.id];
        }
    } else {
        StudentModel *model = self.dataSource[sender.tag];
        model.isSelect = sender.on;
        if (sender.on) {
            self.dictM[model.id] = model;
        } else {
            [self.dictM removeObjectForKey:model.id];
        }
    }
    self.trueButton.enabled = self.dictM.count == 0 ? false : true;
    self.trueButton.selected = self.dictM.count == 0 ? false : true;
}

///  确定选择学生方法
- (void)trueSelectStudentAction {
    if (self.didSelResult) {
        self.didSelResult(self.dictM.allValues);
    }

    NSArray *array = [(UINavigationController *)self.parentViewController viewControllers];
    UIViewController *tovc;
    for (UIViewController *vc in array) {
        if ([vc isKindOfClass:[HWCreatTaskViewController class]]) {
            tovc = vc;
        }
    }
    if (tovc) {
        [self.navigationController popToViewController:tovc animated:true];
    }
}

- (void)loadData {
    HWAddClassViewModel *viewModel = [HWAddClassViewModel new];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        self.dataSource = returnValue;
        [self.tableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [SVProgressHUD dismiss];
    } WithFailureBlock:^{
        [SVProgressHUD dismiss];
    }];
    if (self.addType) {
        [viewModel fetchPublicSmallGroupWtih:self.classId];
    } else {
        [viewModel fetchPublicClassStudentWith:self.classId];
    }
}

- (NSMutableDictionary *)dictM {
    if (!_dictM) {
        _dictM = [NSMutableDictionary dictionary];
    }
    return _dictM;
}

@end
