//
//  HWCreatTaskViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWCreatTaskViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "HWRightLabelTableViewCell.h"
#import "HWAddClassViewController.h"
#import "HWTaskTypeTableViewCell.h"
#import "HWSubjectTableViewCell.h"
#import "SmallGroupStudentModel.h"
#import "HWReleaseTaskTypeView.h"
#import "HWTimerTableViewCell.h"
#import "HWCreatTaskVIewModel.h"
#import "HWReleaseContentCell.h"
#import "HWTaskViewController.h"
#import "HWReleaseButtonCell.h"
#import "SubjectListRequest.h"
#import "HWTaskTimerModel.h"
#import "WDHTTPManager.h"
#import "StudentModel.h"
#import "WDDatePicker.h"
#import "HWSubject.h"

@interface HWCreatTaskViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
///  所有科目数据
@property (nonatomic, strong) NSArray<HWSubject *> *allSubjectData;
///  发布view
@property (nonatomic, strong) HWReleaseTaskTypeView *releaseView;

@property (nonatomic, strong) UIButton *titleButton;
///  标题数据源
@property (nonatomic, copy) NSArray *titleDataSource;
///  右侧阴影view
@property (nonatomic, strong) UIView *rightView;
///  作业类型 1 班级 2 小组 3 个人
@property (nonatomic, assign) NSInteger taskType;
///  班级数据
@property (nonatomic, strong) NSMutableArray *classData;
///  是否是分别定时发布
@property (nonatomic, assign) BOOL respective;
///  是否是定时发布
@property (nonatomic, assign) BOOL timing;
///  科目cell,这个不重用了，太卡
@property (nonatomic, strong) HWSubjectTableViewCell *subjectCell;
///  作业发布类型，1 作业 2 预习 3复习
@property (nonatomic, assign) NSInteger taskReleaseType;
///  发布日期
@property (nonatomic, strong) NSDate *releaseTime;
///  截止日期
@property (nonatomic, strong) NSDate *stopTime;
///  模型id
@property (nonatomic, strong) NSMutableArray *modelId;
///  科目
@property (nonatomic, strong) HWSubject *subject;
///  发布内容cell
@property (nonatomic, strong) HWReleaseContentCell *releaseContentCell;
///  发布状态
@property (nonatomic, assign) NSInteger releaseStatus;
//是否正在发布作业
@property (nonatomic,assign) BOOL isFabu;

@end

@implementation HWCreatTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initView];
    [self loadData];
}

- (void)initNav {
    self.titleButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"按班级立即发布", nil) titleColor:[UIColor whiteColor] backgroundColor:nil];
    UIButton *rightButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"切换", nil) titleColor:[UIColor whiteColor] backgroundColor:nil];
    [self.titleButton addTarget:self action:@selector(changeSubjectAction) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(changeSubjectAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)initView {
//    self.automaticallyAdjustsScrollViewInsets = false;
    WEAKSELF(self);
    self.tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[HWSubjectTableViewCell class] forCellReuseIdentifier:@"HWSubjectTableViewCell"];
    [self.tableView registerClass:[HWTaskTypeTableViewCell class] forCellReuseIdentifier:@"HWTaskTypeTableViewCell"];
    [self.tableView registerClass:[HWTimerTableViewCell class] forCellReuseIdentifier:@"HWTimerTableViewCell"];
    [self.tableView registerClass:[HWRightLabelTableViewCell class] forCellReuseIdentifier:@"HWRightLabelTableViewCell"];
    [self.tableView registerClass:[HWReleaseContentCell class] forCellReuseIdentifier:@"HWReleaseContentCell"];
    [self.tableView registerClass:[HWReleaseButtonCell class] forCellReuseIdentifier:@"HWReleaseButtonCell"];
    [self.view addSubview:self.tableView];
    self.tableView.sectionHeaderHeight = 10;
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsZero];
    
    self.releaseView = [HWReleaseTaskTypeView new];
    self.releaseView.alpha = 0.0;
    self.releaseStatus = 3;
    
    self.releaseView.selAndCancel = ^ {
        [weakSelf changeSubjectAction];
    };
    self.releaseView.didSel = ^ (NSInteger status) {
        
        weakSelf.releaseStatus = status;
        [weakSelf.titleButton setTitle:NSLocalizedString(weakSelf.titleDataSource[status], nil) forState:UIControlStateNormal];
        if (status < 4) {
            weakSelf.taskType = 1; // 班级
        } else if (status > 4 && status < 8) {
            weakSelf.taskType = 2; // 小组
        } else if (status > 9 && status < 12) {
            weakSelf.taskType = 3; // 个人
        }
        weakSelf.respective = (status == 1 || status == 5) ? true : false;
        weakSelf.timing = (status == 2 || status == 6 || status == 10) ? true : false;
        [weakSelf.classData removeAllObjects];
        [weakSelf.modelId removeAllObjects];
        [weakSelf.tableView reloadData];
        [weakSelf changeSubjectAction];
    };
    [self.view addSubview:self.releaseView];
    [self.releaseView zk_Fill:self.view insets:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    self.rightView = [UIView new];
    [self.view addSubview:self.rightView];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.view);
        make.width.offset(1);
    }];
    self.rightView.backgroundColor = [UIColor hex:0x000000 alpha:0.1];
    [self.rightView getShadowOnLeft];
    ///  默认班级
    self.taskType = 1;
    self.classData = [NSMutableArray array];
    self.taskReleaseType = 1;
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)changeSubjectAction {
    self.titleButton.selected = !self.titleButton.isSelected;
    [UIView animateWithDuration:0.5 animations:^{
        self.releaseView.alpha = self.titleButton.selected ? 1.0 : 0.0;
    }];
    [self.releaseView showChangeReleaseTypeWith:self.titleButton.isSelected];
}

#pragma mark - tableView delegate and dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) { // 类型
        return 2;
    } else if (section == 3) {
        return self.classData.count;
    } else if (section == 4) {
        return self.timing ? 2 : 1;
    } else if (section == 5) {
        return 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {return 0;}
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 30;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        CGFloat h = 40;  return ((self.allSubjectData.count / 3 + (self.allSubjectData.count % 3 > 0 ? 1 : 0)) * h) + 10;
    } else if (indexPath.section == 1) {
        return indexPath.row == 0 ? 45 : 650;
    } else if (indexPath.section == 3) {
        return self.respective ? 90 : 40;
    } else if (indexPath.section == 5) {
        return 70;
    }
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return [self getSubjectCellWith:indexPath];
    } else if (indexPath.section == 0 && indexPath.row == 1) { // 科目cell
        return [self getSubjectSlectCellWith:indexPath];
    } else if (indexPath.section == 1 && indexPath.row == 0) { // 作业类型
        return [self getTaskTypeCellWith:indexPath];
    } else if (indexPath.section == 1 && indexPath.row == 1) { // 作业名称
        return [self getTaskNameAndTaskContentCellWith:indexPath];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        return [self getAddClassCellWith:indexPath];
    } else if (indexPath.section == 3) {
        return [self getClassDetailTimeCellWith:indexPath];
    } else if (indexPath.section == 4) {
        return [self getReleaseAndStopTimeCellWith:indexPath];
    } else if (indexPath.section == 5) {
        return [self getReleaseButtonCellWith:indexPath];
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WEAKSELF(self);
    if (indexPath.section == 2 && indexPath.row == 0) {
        HWAddClassViewController *vc = [HWAddClassViewController new];
        vc.subject = self.subject;
        vc.addType = self.taskType;
        vc.didResult = ^(NSArray *data) {
            for (StudentModel *item in data) {
                if (![weakSelf.modelId containsObject:[item id]]) {
                    HWTaskTimerModel *model = [HWTaskTimerModel new];
                    model.id = [item id];
                    model.name = weakSelf.taskType == 2 ? [(SmallGroupStudentModel *)item smallGroupName] : [item name];
                    if (weakSelf.taskType == 3) {
                        model.classId = [item classId];
                    }
                    model.date = [NSDate date];
                    [weakSelf.classData addObject:model];
                    [weakSelf.modelId addObject:[item id]];
                }
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
        };
        [self.navigationController pushViewController:vc animated:true];
    } else if (indexPath.section == 4) {
        
        WDDatePicker *dateV = [WDDatePicker showTimeSelectWith:self.view date:(weakSelf.timing && indexPath.row == 0) ? weakSelf.releaseTime : weakSelf.stopTime];
        dateV.didTime = ^(NSDate *date) {
            if (weakSelf.timing && indexPath.row == 0) {
                weakSelf.releaseTime = date;
            } else {
                weakSelf.stopTime = date;
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
}

- (UITableViewCell *)getSubjectCellWith:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"学科选择", nil)];
    cell.textLabel.textColor = [UIColor hex:0x2F9B8C alpha:1.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (UITableViewCell *)getTaskNameAndTaskContentCellWith:(NSIndexPath *)indexPath {
    if (self.releaseContentCell) {
        return self.releaseContentCell;
    } else {
        self.releaseContentCell = [self.tableView dequeueReusableCellWithIdentifier:@"HWReleaseContentCell" forIndexPath:indexPath];
        self.releaseContentCell.superViewController = self;
        return self.releaseContentCell;
    }
}

- (UITableViewCell *)getSubjectSlectCellWith:(NSIndexPath *)indexPath {
    if (self.subjectCell) {
        return self.subjectCell;
    } else {
        HWSubjectTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWSubjectTableViewCell" forIndexPath:indexPath];
        WEAKSELF(self);
        cell.didSelectSubject = ^(HWSubject *sub) {
            weakSelf.subject = sub;
            weakSelf.releaseContentCell.nameTextField.text = sub.subjectCH;
        };
        [cell setValueForDataSource:self.allSubjectData];
        if (self.allSubjectData.count > 0) {
            self.subjectCell = cell;
        }
        return cell;
    }
}

- (UITableViewCell *)getTaskTypeCellWith:(NSIndexPath *)indexPath {
    WEAKSELF(self);
    HWTaskTypeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWTaskTypeTableViewCell" forIndexPath:indexPath];
    cell.didSelType = ^(NSInteger type) {
        weakSelf.taskReleaseType = type;
    };
    return cell;
}

- (UITableViewCell *)getAddClassCellWith:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = NSLocalizedString(self.taskType == 1 ? @"添加班级" : (self.taskType == 2 ? @"添加小组" : @"添加个人"), nil);
    cell.textLabel.textColor = [UIColor hex:0x2F9B8C alpha:1.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)getClassDetailTimeCellWith:(NSIndexPath *)indexPath {
    if (self.respective) {
        HWTimerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWTimerTableViewCell" forIndexPath:indexPath];
        [cell setValueForDataSource:self.classData[indexPath.row]];
        [cell.selTimeButton addTarget:self action:@selector(selectTimeWith:) forControlEvents:UIControlEventTouchUpInside];
        [cell.delButton addTarget:self action:@selector(deleteAddClassSmallGroupCellWith:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        cell.textLabel.text = [self.classData[indexPath.row] name];
        cell.textLabel.textColor = [UIColor grayColor];
        UIButton *del = [UIButton buttonWithFont:[UIFont fontWithName:@"iconfont" size:24] title:@"\U0000e624" titleColor:[UIColor hex:0xFB5F22 alpha:1.0] backgroundColor:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [del addTarget:self action:@selector(deleteAddClassSmallGroupCellWith:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = del;
        [cell getShadowOnBottom];
        return cell;
    }
}

- (UITableViewCell *)getReleaseAndStopTimeCellWith:(NSIndexPath *)indexPath {
    HWRightLabelTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWRightLabelTableViewCell" forIndexPath:indexPath];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd hh:mm";
    
    if (self.timing && indexPath.row == 0) { // 发布日期
        cell.textLabel.text = NSLocalizedString(@"发布日期", nil);
        dateFormater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
        cell.rightLabel.text = [NSString stringWithFormat:@"%@", [dateFormater stringFromDate:self.releaseTime]];
        cell.textLabel.textColor = [UIColor grayColor];
        [cell getShadowOnBottom];
    } else { // 截止日期
        cell.textLabel.text = NSLocalizedString(@"截止日期", nil);
        cell.textLabel.textColor = [UIColor hex:0xFB4E09 alpha:1.0];
        dateFormater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
        cell.rightLabel.text = [NSString stringWithFormat:@"%@", [dateFormater stringFromDate:self.stopTime]];
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return cell;
}

- (UITableViewCell *)getReleaseButtonCellWith:(NSIndexPath *)indexPath {
    HWReleaseButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HWReleaseButtonCell" forIndexPath:indexPath];
    [cell.releaseButton addTarget:self action:@selector(releaseTaskAction) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)releaseTaskAction {
    if (self.isFabu) return;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyyMMddhhmm";
    dateFormater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    
    dictM[@"jsID"] = [WDTeacher sharedUser].teacherID; // 教师id
    if (!self.subject) { [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请选择科目", nil)]; return; }
    dictM[@"kmID"] = self.subject.subjectID; // 科目
    dictM[@"zyfl"] = [dictM[@"kmID"] isEqualToString:@""] ? @"9" : @"1"; // 1普通 9其他
    dictM[@"zyxz"] = @"1"; // 非在线
    NSString *stopStr = [NSString stringWithFormat:@"%@", [dateFormater stringFromDate:self.stopTime]];
    dictM[@"zyjzrq"] = [stopStr stringByReplacingOccurrencesOfString:@":" withString:@""]; // 截止日期
    dictM[@"fbdxlx"] = [NSString stringWithFormat:@"%ld", (long)self.taskType]; // 发布对象类型 1班级 2小组 3个人
    [dictM addEntriesFromDictionary:[self.releaseContentCell releaseTaskAction]];
    if ([dictM[@"zymc"] length] == 0) { [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入作业名称", nil)]; return ; }
    if (self.classData.count == 0) { [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请选择发布对象", nil)]; return ; }
    if ([dictM[@"wznr"] isEqualToString:@""]) { [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入作业内容", nil)]; return ; }

    BOOL isCurrentSubmit = [@[@3, @7, @11] containsObject:@(self.releaseStatus)];
    NSMutableArray *fbdxList = [NSMutableArray array];
//    NSString *time = isCurrentSubmit ? @"" : [NSString stringWithFormat:@"%ld", (long)[self.releaseTime timeIntervalSince1970]];
//    if (self.timing) {
//        NSDate *date = [NSDate date];
//        NSTimeZone *zone = [NSTimeZone systemTimeZone];
//        NSInteger interval = [zone secondsFromGMTForDate: date];
//        self.releaseTime = [_releaseTime dateByAddingTimeInterval:-interval];
//        time = isCurrentSubmit ? @"" : [NSString stringWithFormat:@"%ld", (long)[self.releaseTime timeIntervalSince1970]];
//    }
    
    self.releaseTime = [self.releaseTime dateByAddingTimeInterval:-60 * 60 * 8];
    for (HWTaskTimerModel *item in self.classData) {
        NSMutableDictionary *fbdxM = [NSMutableDictionary dictionary];
        fbdxM[@"fbdxID"] = item.id;
        fbdxM[@"grssbjID"] = item.classId;
        if ([@[@2, @6, @10] containsObject:@(self.releaseStatus)]) { // 定时发布
            fbdxM[@"fbSJ"] = [NSString stringWithFormat:@"%ld", (long)self.releaseTime.timeIntervalSince1970];
        } else if ([@[@3, @7, @11] containsObject:@(self.releaseStatus)]) { // 立即发布
            fbdxM[@"fbSJ"] = @"";
        } else if ([@[@1, @5] containsObject:@(self.releaseStatus)]) { // 分别发布
            fbdxM[@"fbSJ"] = [NSString stringWithFormat:@"%ld", (long)[item.date timeIntervalSince1970]];
        }
        
        [fbdxList addObject:fbdxM];
    }
    if (fbdxList.count > 0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:fbdxList options:0 error:nil];
        dictM[@"fbdxList"] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    self.isFabu = YES;
    [SVProgressHUD show];
    WEAKSELF(self);
    NSString *url = [NSString stringWithFormat:@"%@/zyv1!%@.action",EDU_BASE_URL,@"postFZXZY"];
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:dictM urlString:url finished:^(NSDictionary *dict) {
        [SVProgressHUD dismiss];
        if (dict) {
            if ([dict[@"isSuccess"] isEqualToString:@"true"]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"发布成功", nil)];
                HWTaskViewController *vc = (HWTaskViewController *)weakSelf.navigationController.viewControllers.firstObject;
                [vc loadDataWithKMid:vc.subjectID];
                self.isFabu = NO;
                [weakSelf.navigationController popViewControllerAnimated:true];
            } else {
                self.isFabu = NO;
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"作业发布失败，请稍候重新发布", nil)];
                return ;
            }
        } else {
            self.isFabu = NO;
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"作业发布失败，请稍候重新发布", nil)];
        }
    }];
}

- (void)deleteAddClassSmallGroupCellWith:(UIButton *)sender {
    NSIndexPath *index = [self.tableView indexPathForCell:(UITableViewCell *)sender.superview];
    if (!index) {
        index = [self.tableView indexPathForCell:(UITableViewCell *)sender.superview.superview];
    }
    [self.classData removeObjectAtIndex:index.row];
    [self.modelId removeObjectAtIndex:index.row];
    [self.tableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)selectTimeWith:(UIButton *)sender {
    NSIndexPath *index = [self.tableView indexPathForCell:(UITableViewCell *)sender.superview.superview];
    HWTaskTimerModel *model = self.classData[index.row];
//    model.date = [model.date dateByAddingTimeInterval:60 * 60 * 8];
    WDDatePicker *dateV = [WDDatePicker showTimeSelectWith:self.view date:[model.date dateByAddingTimeInterval:60 * 60 * 8]];
    WEAKSELF(self);
    dateV.didTime = ^(NSDate *date) {
        model.date = [date dateByAddingTimeInterval:-60 * 60 * 8];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
    };
}

- (void)loadData {
    HWCreatTaskVIewModel *viewModel = [HWCreatTaskVIewModel new];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        self.allSubjectData = returnValue;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.subjectCell collectionView:self.subjectCell.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    } WithErrorBlock:^(id errorCode) {
        [SVProgressHUD dismiss];
    } WithFailureBlock:^{
        [SVProgressHUD dismiss];
    }];
    [viewModel fetchPublicAllSubjectAction];
    [SVProgressHUD show];
}

- (NSArray *)titleDataSource {
    return @[@"", @"按班级分别发布", @"按班级定时发布", @"按班级立即发布", @"", @"按小组分别发布",  @"按小组定时发布", @"按小组立即发布", @"", @"", @"按个人定时发布", @"按个人立即发布"];
}

- (NSDate *)releaseTime {
    if (!_releaseTime) {
        NSDate *date = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        _releaseTime = [date dateByAddingTimeInterval: interval];
    }
    return _releaseTime;
}

- (NSDate *)stopTime {
    if (!_stopTime) {
        NSDate *tempDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [dateFormatter stringFromDate:tempDate];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *trueDate = [NSString stringWithFormat:@"%@ 08:00", dateStr];
        NSDate *date = [dateFormatter dateFromString:trueDate];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        _stopTime = [date  dateByAddingTimeInterval: interval];
    }
    return _stopTime;
}

- (NSMutableArray *)modelId {
    if (!_modelId) {
        _modelId = [NSMutableArray array];
    }
    return _modelId;
}

@end
