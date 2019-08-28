//
//  MOAddClassViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "MOAddClassViewController.h"
#import "PersonalInfoTableViewCell.h"
#import "MyClassViewController.h"
#import "MOTrueTableViewCell.h"
#import "MOSelectSubjectCell.h"
#import "MOSelectClassView.h"
#import "WDHTTPManager.h"
#import "ClassModel.h"
#import "HWSubject.h"

@interface MOAddClassViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;
///  班主任
@property (nonatomic, strong) UISwitch *teacherSwitch;
///  任课老师
@property (nonatomic, strong) UISwitch *cTeacherSwitch;
///  是否添加科目
@property (nonatomic, assign) BOOL isAddSubject;
///  年级数据
@property (nonatomic, copy) NSArray *gradeData;
///  年级id数据
@property (nonatomic, copy) NSArray *gradeIdData;
///  班级列表
@property (nonatomic, copy) NSArray *classList;
///  科目列表
@property (nonatomic, copy) NSArray *subjectList;

@property (nonatomic, strong) NSMutableDictionary *classData;
///  当前选择的年级id
@property (nonatomic, copy) NSString *currentGradeId;
///  当前选择的班级id
@property (nonatomic, copy) NSString *cSelClassId;
///  科目cell高度
@property (nonatomic, assign) CGFloat subjectCellH;
///  当前选择的年级
@property (nonatomic, copy) NSString *selectGradeStr;
///  当前选择班级
@property (nonatomic, copy) NSString *selectClassStr;
///  选择科目cell
@property (nonatomic, strong) MOSelectSubjectCell *selsubCell;

@end

@implementation MOAddClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    self.title = NSLocalizedString(@"加入班级",  nil);
    self.tableView = [UITableView tableViewWithSuperView:self.view dataSource:self backgroundColor:[UIColor hex:0xF5F2F9 alpha:1.0] separatorStyle:UITableViewCellSeparatorStyleSingleLine registerCell:[PersonalInfoTableViewCell class] cellIdentifier:@"PersonalInfoTableViewCell"];
    [self.tableView zk_Fill:self.view insets:UIEdgeInsetsZero];
    [self.tableView registerClass:[MOTrueTableViewCell class] forCellReuseIdentifier:@"MOTrueTableViewCell"];
    [self.tableView registerClass:[MOSelectSubjectCell class] forCellReuseIdentifier:@"MOSelectSubjectCell"];
    self.dataSource = @[@[NSLocalizedString(@"选择年级", nil)], @[NSLocalizedString(@"选择班级", nil)], @[NSLocalizedString(@"班主任", nil), NSLocalizedString(@"任课老师", nil)].mutableCopy, @[@""]].mutableCopy;
    self.tableView.tableFooterView = [UIView new];
    
    self.teacherSwitch = [UISwitch new];
    self.cTeacherSwitch = [UISwitch new];
}

#pragma mark - tableView delegate and dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0 && self.isAddSubject) {
        return self.subjectCellH + 0.5;
    }
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView viewWithBackground:[UIColor clearColor] alpha:1.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 3) {
        MOTrueTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOTrueTableViewCell" forIndexPath:indexPath];
        [cell.trueButton addTarget:self action:@selector(addClassAction) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    if (indexPath.section == 2 && indexPath.row == 0 && self.isAddSubject) { return [self getSelectSubjectCellWith:indexPath]; }
    
    PersonalInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PersonalInfoTableViewCell" forIndexPath:indexPath];
    cell.accessoryType = (indexPath.section == 0 || indexPath.section == 1) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) { [cell setValueForDataSource:self.selectGradeStr]; }
    if (indexPath.section == 1) { [cell setValueForDataSource:self.selectClassStr]; }
    if (indexPath.section == 2) {
        if (self.isAddSubject) {
            if (indexPath.row == 1 || indexPath.row == 2) {
                cell.accessoryView = indexPath.row == 1 ? self.teacherSwitch : self.cTeacherSwitch;
            }
        } else {
            if (indexPath.row == 0 || indexPath.row == 1) {
                cell.accessoryView = indexPath.row == 0 ? self.teacherSwitch : self.cTeacherSwitch;
            }
        }
    }
    
    return cell;
}

- (UITableViewCell *)getSelectSubjectCellWith:(NSIndexPath *)indexPath {
    
    MOSelectSubjectCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSelectSubjectCell" forIndexPath:indexPath];
    
    NSArray *subs = nil;
    for (ClassModel *item in self.myClassData) {
        if ([item.id isEqualToString:self.cSelClassId]) {
            subs = item.kmList.copy;
            break;
        }
    }
    for (HWSubject *item in self.subjectList) { item.isSel = false; }
    if (subs) {
        for (HWSubject *item in self.subjectList) {
            for (HWSubject *it in subs) {
                if ([item.subjectID isEqualToString:it.subjectID]) {
                    item.isSel = true;
                    continue;
                }
            }
        }
    }
    cell.data = self.subjectList;
    [cell.collectionView layoutIfNeeded];
    self.subjectCellH = cell.collectionView.contentSize.height;
    self.selsubCell = cell;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAKSELF(self);
    if (indexPath.section == 0) { // 选择年级
        
        MOSelectClassView *selv = [MOSelectClassView showClassSelectWith:self.view title:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"选择年级", nil)] data: self.gradeData];
        selv.didSel = ^(NSIndexPath *index) {
            weakSelf.currentGradeId = weakSelf.gradeIdData[index.row];
            weakSelf.selectGradeStr = NSLocalizedString(weakSelf.gradeData[index.row], nil);
            weakSelf.selectClassStr = @"";
            for (HWSubject *item in weakSelf.subjectList) { item.isSel = false; }
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf loadData];
        };
    } else if (indexPath.section == 1) { // 选择班级
        if (!self.currentGradeId) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请先选择年级", nil)];
            return ;
        }
        NSArray *keys = self.classData.allKeys;
        if (keys.count == 0) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"当前年级无可选班级", nil)];
            return ;
        }
        MOSelectClassView *selv = [MOSelectClassView showClassSelectWith:self.view title:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"请选择班级", nil)] data:keys];
        selv.didSel = ^(NSIndexPath *index) {
            weakSelf.cSelClassId = weakSelf.classData[keys[index.row]];
            weakSelf.selectClassStr = keys[index.row];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
}

#pragma mark - custom action
- (void)loadData {
    NSDictionary *parameter = @{@"njID": self.currentGradeId,
                                @"xxID":[WDTeacher sharedUser].schoolID};
    WEAKSELF(self);
    [SVProgressHUD show];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:parameter urlString:[NSString stringWithFormat:@"%@/gd!getBJandKM.action",EDU_BASE_URL] finished:^(NSDictionary *data) {
        [SVProgressHUD dismiss];
        weakSelf.classList = data[@"bjList"];
        
        NSArray *subList = data[@"kmList"];
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *item in subList) {
            [arrayM addObject:[HWSubject subjectWithDictIDAndMC:item]];
        }
        weakSelf.subjectList = arrayM;
        
        [weakSelf.classData removeAllObjects];
        for (NSDictionary *item in weakSelf.classList) {
            weakSelf.classData[item[@"bjmc"]] = item[@"bjID"];
        }
        if (!weakSelf.isAddSubject) {
            weakSelf.isAddSubject = true;
            NSMutableArray *array = self.dataSource[2];
            [array insertObject:@"" atIndex:0];
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

///  添加班级方法
- (void)addClassAction {
    WEAKSELF(self);
    if (!self.currentGradeId) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请先选择年级", nil)];
        return ;
    }
    if (!self.cSelClassId) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"您还未选择班级", nil)];
        return ;
    }
    
    if (!self.teacherSwitch.isOn && !self.cTeacherSwitch.isOn) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请选择添加班主任或任课老师", nil)];
        return;
    }
    
    if (self.teacherSwitch.isOn) { // 添加班主任
        NSDictionary *parameter = @{@"jsID":[WDTeacher sharedUser].teacherID,
                                   @"bjID": self.cSelClassId,
                                   @"jsjs":@"01"};
        
        [self addTeacherActionWith:parameter handler:^(BOOL isSuccess){

            if (weakSelf.cTeacherSwitch.on) {
                NSString *str = [weakSelf.selsubCell getNeedAddSubjectIdData];
                if (str.length == 0) { [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"您还未选择需要添加的科目", nil)]; return ; }
                NSDictionary *parameter1 = @{@"jsID":[WDTeacher sharedUser].teacherID,
                                            @"bjID": weakSelf.cSelClassId,
                                            @"jsjs":@"02",
                                            @"km":str};
                [weakSelf addCourseTeacherAction:parameter1];
            } else {
                if (isSuccess) {
                    MyClassViewController *myvc = [weakSelf.navigationController viewControllers][1];
                    [myvc loadData];
                    [weakSelf.navigationController popViewControllerAnimated:true];
                }
            }
        }];
        return ;
    }
    if (self.cTeacherSwitch.isOn) {
        NSString *str = [weakSelf.selsubCell getNeedAddSubjectIdData];
        if (str.length == 0) { [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"您还未选择需要添加的科目", nil)]; return ; }
        NSDictionary *parameter1 = @{@"jsID":[WDTeacher sharedUser].teacherID,
                                     @"bjID": weakSelf.cSelClassId,
                                     @"jsjs":@"02",
                                     @"km":str};
        [weakSelf addCourseTeacherAction:parameter1];
    }
}

- (void)addTeacherActionWith:(NSDictionary *)parameter handler:(void(^)(BOOL))handler {
    WEAKSELF(self);
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:parameter urlString:[NSString stringWithFormat:@"%@/gd!addBJ.action",EDU_BASE_URL] finished:^(NSDictionary * data) {
        
        if ([data[@"isSuccess"] isEqualToString:@"yybzr"]) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"加入班级失败,该班已有班主任", nil)];
            [weakSelf.teacherSwitch setOn:false animated:true];
            handler(false);
        } else if ([data[@"isSuccess"] isEqualToString:@"true"]) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"班级添加成功", nil)]; // 成功
            handler(true);
        } else {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"加入班级失败", nil)]; // 失败
            [weakSelf.teacherSwitch setOn:false animated:true];
            handler(false);
        }
    }];
}

- (void)addCourseTeacherAction:(NSDictionary *)parameter {
    WEAKSELF(self);
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:parameter urlString:[NSString stringWithFormat:@"%@/gd!addBJ.action",EDU_BASE_URL] finished:^(NSDictionary * data) {
        if ([data[@"isSuccess"] isEqualToString:@"true"]) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"班级添加成功", nil)]; // 成功
            MyClassViewController *myvc = [weakSelf.navigationController viewControllers][1];
            [myvc loadData];
            [weakSelf.navigationController popViewControllerAnimated:true];
            
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"加入班级失败", nil)]; // 失败
        }
    }];
}

- (NSArray *)gradeData {
    return @[
             @"一年级",
             @"二年级",
             @"三年级",
             @"四年级",
             @"五年级",
             @"六年级（六三制）",
             @"六年级（五四制）",
             @"七年级",
             @"八年级",
             @"九年级",
             @"高一",
             @"高二",
             @"高三"
             ];
}

- (NSArray *)gradeIdData {
    return @[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13"];
}

- (NSMutableDictionary *)classData {
    if (!_classData) {
        _classData = [NSMutableDictionary dictionary];
    }
    return _classData;
}

@end
