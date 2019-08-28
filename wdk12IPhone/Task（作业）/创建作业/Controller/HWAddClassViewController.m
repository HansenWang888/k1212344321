//
//  HWAddClassViewController.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWAddClassViewController.h"
#import "HWAddSmallGroupViewController.h"
#import "HWAddClassViewModel.h"
#import "ClassModel.h"
#import "HWSubject.h"

@interface HWAddClassViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
///  右侧阴影view
@property (nonatomic, strong) UIView *rightView;
///  确定按钮
@property (nonatomic, strong) UIButton *trueButton;
///  班级数据源
@property (nonatomic, strong) NSMutableDictionary *dictM;

@end

@implementation HWAddClassViewController

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
    titleLabel.text = NSLocalizedString(@"请选择班级", nil);
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    
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
    ClassModel *model = self.dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = model.name;
    if (self.addType == 1) {
        UISwitch *sw = [UISwitch new];
        sw.tag = indexPath.row;
        [sw addTarget:self action:@selector(selectClassWith:) forControlEvents:UIControlEventValueChanged];
        sw.on = model.isSelect;
        cell.accessoryView = sw;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.addType == 1) {
        return ;
    }
    HWAddSmallGroupViewController *vc = [HWAddSmallGroupViewController new];
    vc.addType = self.addType == 2 ? true : false;
    ClassModel *model = self.dataSource[indexPath.row];
    vc.classId = model.id;
    
    __weak HWAddClassViewController *weakSelf = self;
    vc.didSelResult = ^(NSArray *data) {
        weakSelf.didResult(data);
    };
    [self.navigationController pushViewController:vc animated:true];
}

///  确定选择学生方法
- (void)trueSelectStudentAction {
    if (self.didResult) {
        self.didResult(self.dictM.allValues);
    }
    [self.navigationController popViewControllerAnimated:true];
}

///  选择班级
- (void)selectClassWith:(UISwitch *)sender {
    ClassModel *model = self.dataSource[sender.tag];
    model.isSelect = sender.on;
    if (sender.on) {
        self.dictM[model.id] = model;
    } else {
        [self.dictM removeObjectForKey:model.id];
    }
    self.trueButton.enabled = self.dictM.count == 0 ? false : true;
    self.trueButton.selected = self.dictM.count == 0 ? false : true;
}

- (void)loadData {
    HWAddClassViewModel *viewModel = [HWAddClassViewModel new];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (ClassModel *item in returnValue) {
            for (NSString *str in item.kmList) {
                if ([str isEqualToString:self.subject.subjectID]) {
                    [arrayM addObject:item];
                    continue;
                }
            }
        }
        self.dataSource = arrayM;
        if ([self.subject.subjectID isEqualToString:@""]) {
            self.dataSource = returnValue;
        }        [self.tableView reloadData];
    } WithErrorBlock:^(id errorCode) {
    } WithFailureBlock:^{
    }];
    [viewModel fetchPublicAllClassroomList];
}

- (NSMutableDictionary *)dictM {
    if (!_dictM) {
        _dictM = [NSMutableDictionary dictionary];
    }
    return _dictM;
}


@end
