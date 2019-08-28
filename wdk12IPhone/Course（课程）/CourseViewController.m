//
//  CourseViewController.m
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "CourseViewController.h"
#import "DateTableViewCell.h"
#import "WDTitleButton.h"
#import "WDCourse.h"
#import "WDCourseList.h"
#import "WDPromptView.h"
#import "WDPromptImageView.h"
#import "ScheduleTableViewCell.h"
#import "HWClassesExerciseVC.h"
#import "WDSchedulerView.h"
#import "WDHTTPManager.h"
#import "WDLoginModule.h"

@interface CourseViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UITabBarControllerDelegate> {
    NSIndexPath * todayIndexPath;
}

@property (nonatomic, strong) UITableView *leftTableV;
@property (nonatomic, strong) UITableView *rightTableV;
@property (nonatomic, strong) UILabel *titleDate;
@property (nonatomic, strong) NSDictionary *dayDict;
@property (nonatomic, strong) NSArray *courseArray;//课表数据
@property (nonatomic, strong) NSIndexPath *leftIndex;//记录左边表格的cell
@property (nonatomic, strong) UIView *dateView;
@property (nonatomic, copy) NSString *currentID;//当前加载数据要使用的ID
@property (nonatomic, copy) NSString *currentKey;//当前加载数据要使用的参数key
@property (nonatomic, copy) NSString *currentMethod;//当前加载数据要使用的方法名
@property (nonatomic, strong) WDTitleButton *titleBtn;//标题按钮
@property (nonatomic, strong) WDPromptView *promptV;
@property (nonatomic, strong) WDPromptImageView * promptImageView;
@property (assign, nonatomic) BOOL isScheduler;
///  是否是我的课表
@property (nonatomic, assign) BOOL isMySchedule;

@property (nonatomic, strong) WDSchedulerView *schedulerView;//选择班级view
@property (nonatomic, strong) UIView *backView;//底视图

@end

@implementation CourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self requestForMyClass];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSubViewToView];
    self.currentID = [WDTeacher sharedUser].teacherID;
    self.currentKey = @"userID";
    self.currentMethod = @"getDKJSKBList";
    [self refreshDataWithparamKey:self.currentKey ID:self.currentID andMethod:self.currentMethod isSQL:YES];
    self.isMySchedule = true;

    NSArray *codeArr = [ServerManager sharedManager].codeArr;
    if ([codeArr containsObject:@"exercise"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"课堂练习", nil) style:0 target:self action:@selector(rightBtnClick)];
    }
}
- (void)rightBtnClick {
    HWClassesExerciseVC *vc = [HWClassesExerciseVC new];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //删除掉网络出错页面
    [self.promptV setPromtVWithHidden:YES isAnimation:YES activityHidden:YES promtStr:nil];
    self.promptImageView.hidden = YES;
    
    [SVProgressHUD dismiss];
}
- (NSString *)appendStudentClassesIDWithArray:(NSArray *)array {
   
    NSMutableString *classesStr = [NSMutableString string];
    for (NSDictionary *dict in array) {
        [classesStr appendFormat:@"%@,",dict[@"bjID"]];
    }
    return classesStr.copy;
}
#pragma mark -- 请求我的班级数据
- (void)requestForMyClass {
    WDTeacher * teacher = [WDTeacher sharedUser];
    
    [[WDHTTPManager sharedHTTPManeger] loginIDWithUserInfo:teacher.loginID userType:[WDUser sharedUser].userType  finished:^(NSDictionary * ruledic) {
        NSArray *array = ruledic[@"jsjsxxList"];
        
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dd in array) {
            if ([dd[@"jsjs"] isEqualToString:@"01"]) {
                [WDTeacher sharedUser].masterList = dd[@"bjList"];
            }else {
                [arrayM addObject:dd];
            }
        }
        [WDTeacher sharedUser].teacherList = arrayM.copy;
        [self.view bringSubviewToFront:self.backView];
        [self.view bringSubviewToFront:self.schedulerView];
    }];
}

# pragma mark按钮点击
- (void)btnClick:(UIButton *)btn{
    
    if (btn.tag == 11) {
        //左边按钮
        NSArray *array = [self getDateForTitleDate];
        int year = [array[0] intValue];
        int month = [array[1] intValue];
        month--;
        if (month % 12 == 0) {
            year -= 1;
            month = 12;
        }
        self.titleDate.text = [NSString stringWithFormat:@"%d%@ %d%@",year,NSLocalizedString(@"年", nil), month, NSLocalizedString(@"月", nil)];
        [self.leftTableV reloadData];
        [self.titleDate sizeToFit];
        [self refreshChoose];
    }else {
        NSArray *array = [self getDateForTitleDate];
        int year = [array[0] intValue]; 
        int month = [array[1] intValue];
        month++;
        if (month == 13) {
            year += 1;
            month = 1;
        }
        self.titleDate.text = [NSString stringWithFormat:@"%d%@ %d%@",year, NSLocalizedString(@"年", nil), month, NSLocalizedString(@"月", nil)];
        [self.leftTableV reloadData];
        [self.titleDate sizeToFit];
        [self refreshChoose];
    }
}

- (void)refreshChoose {
    [self.leftTableV selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    if (self.rightTableV.visibleCells.count > 0) {
        [self.rightTableV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
    }
    [self refreshDataWithparamKey:self.currentKey ID:self.currentID andMethod:self.currentMethod isSQL:YES];
}

// 标题按钮点击
- (void)titleBtnClick:(WDTitleButton *)btn {
    if (self.schedulerView.hidden) {
        [self showSchedulerView];
    }else {
        [self hiddenSchedulerView];
    }
}

- (void)showSchedulerView {
    self.schedulerView.hidden = NO;
    self.backView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.schedulerView.y += CGRectGetHeight(self.schedulerView.frame);
    }];
}

- (void)hiddenSchedulerView {
    if (self.schedulerView.hidden) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.schedulerView.y -= CGRectGetHeight(self.schedulerView.frame);
    } completion:^(BOOL finished) {
        self.schedulerView.hidden = YES;
        self.backView.hidden = YES;
    }];
}

//刷新点击
- (void)refreshClick {
    NSIndexPath *indexPath = [self.leftTableV indexPathForSelectedRow];
    [self.leftTableV selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
    [self refreshDataWithparamKey:self.currentKey ID:self.currentID andMethod:self.currentMethod isSQL:NO];
}

- (void)clickTopToday {
    //把月份变成当前月份
    //获取当天时间
    NSDateComponents *compoentsDate = [self getYearAndMonth];
    NSString *dateToString = [NSString stringWithFormat:@"%d%@ %d%@",(int)compoentsDate.year, NSLocalizedString(@"年", nil), (int)compoentsDate.month, NSLocalizedString(@"月", nil)];
    self.titleDate.text = dateToString;
    [self.titleDate sizeToFit];
    [self.leftTableV reloadData];
    //设置cell点击状态是当天的
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:todayIndexPath.row inSection:0];
    [self.leftTableV selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    //更新数据
    [self tableView:self.leftTableV didSelectRowAtIndexPath:todayIndexPath];
    [self.leftTableV scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
}

# pragma mark 计算天数 日期
- (int)yearAndMonthOfdays:(NSInteger)year month:(NSInteger)month{
    
    NSArray *thirting = @[@"1",@"3",@"5",@"7",@"8",@"10",@"12"];
    NSArray *tunting = @[@"4",@"6",@"9",@"11"];
    NSString *mothD = [NSString stringWithFormat:@"%ld",(long)month];
    if ([thirting containsObject:mothD]){
        return [@"31" intValue];
    }else if ([tunting containsObject:mothD]){
        return [@"30" intValue];
    }else if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0){
        //闰年
        return [@"29" intValue];
    }
    return [@"28" intValue];
}

- (NSDateComponents *)getYearAndMonth{
    //得到当前系统日期
    NSDate *date = [NSDate date];
    NSCalendar *current = [NSCalendar currentCalendar];
    NSDateComponents *componts = [current components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return componts;
}

- (NSString *)getWeekdayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day{

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateWithEra:1 year:year month:month day:day hour:0 minute:0 second:0 nanosecond:0];
    NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date];
    return [NSString stringWithFormat:@"%ld",(long)weekday];
}

- (NSArray *)getDateForTitleDate{
    
    NSString *pattern = @"\\d{1,4}";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regular matchesInString:self.titleDate.text options:0 range:NSMakeRange(0, self.titleDate.text.length)];
    NSTextCheckingResult *result = array[0];
    NSTextCheckingResult *result2 = array[1];
    NSString *year = [self.titleDate.text substringWithRange:result.range];
    NSString *month = [self.titleDate.text substringWithRange:result2.range];
    return @[year,month];
}

# pragma mark添加子View
- (void)addSubViewToView{
    //横幅
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, CURRENT_DEVICE_SIZE.width, 45)];
    view.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
  
    
    //添加今天按钮
    UIButton * todayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    todayBtn.frame = CGRectMake(2, 2, 60, 40);
//    todayBtn.backgroundColor = [UIColor redColor];
    [todayBtn setTitle:NSLocalizedString(@"今天", nil) forState:UIControlStateNormal];
    [todayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [todayBtn addTarget:self action:@selector(clickTopToday) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:todayBtn];
    
    
    //得到当前系统日期
    NSDateComponents *compoentsDate = [self getYearAndMonth];
    NSString *dateToString = [NSString stringWithFormat:@"%ld%@ %ld%@",(long)compoentsDate.year, NSLocalizedString(@"年", nil), (long)compoentsDate.month, NSLocalizedString(@"月", nil)];
    UILabel *label  = [[UILabel alloc] init];
    label.text = dateToString;
    [label sizeToFit];
    label.center = CGPointMake(view.center.x, 20);
    [view addSubview:label];
    self.titleDate = label;
    CGFloat centerY = view.frame.size.height / 2;
    CGFloat marginBtn = 80;
    UIButton *leftBtn = [self createButtonWithTTFName:@"\U0000e64f" point:CGPointMake( marginBtn, centerY) tag:11];
    UIButton *rightBtn = [self createButtonWithTTFName:@"\U0000e64e" point:CGPointMake(CURRENT_DEVICE_SIZE.width - marginBtn, centerY) tag:22];
    [view addSubview:leftBtn];
    [view addSubview:rightBtn];
    [self.view addSubview:view];
    self.dateView = view;
    
    //老师
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClick)];
    //标题按钮
    WDTitleButton *btn = [WDTitleButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NSLocalizedString(@"我的课表", nil) forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _titleBtn = btn;
    self.navigationItem.titleView = btn;
    [self.navigationItem.titleView sizeToFit];
    //左边表格
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    [self.leftTableV selectRowAtIndexPath:[NSIndexPath indexPathForRow:today.day - 1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    //右边表格
    [self.view addSubview:self.rightTableV];
}

- (UIButton *)createButtonWithTTFName:(NSString *)TTFName point:(CGPoint)point tag:(NSInteger)tagBtn {
   
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 35, 35);
    leftBtn.titleLabel.font = [UIFont fontWithName:@"iconfont" size:25];
    [leftBtn setTitle:TTFName forState:UIControlStateNormal];
    leftBtn.center = point;
    [leftBtn sizeToFit];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.tag = tagBtn;
    return leftBtn;
}

# pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.leftTableV) { return 1; }
    return self.courseArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableV) {
        return [self yearAndMonthOfdays:[self getYearAndMonth].year month:[self getYearAndMonth].month];
    }
    WDCourse *list = self.courseArray[section];
    return list.courseLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == self.leftTableV) {
        DateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftTableV"];
        if (cell == nil) {
            cell = [DateTableViewCell dateTableViewCell];
        }
        cell.titleCompoents = [self getDateForTitleDate];
        cell.days = indexPath.row + 1;
        if ([cell.upDate.text isEqualToString:NSLocalizedString(@"今天", nil)]) {
            todayIndexPath = indexPath;
        }
        cell.weekday = self.dayDict[[self getWeekdayWithYear:[[self getDateForTitleDate][0]intValue] month:[[self getDateForTitleDate][1]intValue] day:indexPath.row + 1]];
        return cell;
    }
    WDCourse *course = self.courseArray[indexPath.section];
    WDCourseList *cList = course.courseLists[indexPath.row];
    ScheduleTableViewCell *cell = [self.rightTableV dequeueReusableCellWithIdentifier:@"ScheduleTableViewCell" forIndexPath:indexPath];
    [cell setValueForDataSource:cList isMySchedule:self.isMySchedule];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    if (tableView == self.rightTableV) {
        WDCourse *course = self.courseArray[section];
        return course.timeBucket;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if (tableView == self.rightTableV) {
        WDCourse *course = self.courseArray[section];
        UILabel *label = [[UILabel alloc] init];
        label.text = course.timeBucket;
        label.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    }
    return  nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.rightTableV) { return 30; };
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.leftTableV) {
        self.leftIndex = indexPath;
        self.promptImageView.hidden = YES;
        [self refreshDataWithparamKey:self.currentKey ID:self.currentID andMethod:self.currentMethod isSQL:YES];
    }
}

#pragma mark SchedulerControllerDlegate
- (void)schedulerForClassesData:(id)anyData {
    
    self.isScheduler = YES;
    if ([anyData[@"key"] isEqualToString:@"MY"]) {
        //传入MY代表是查找我的课表
        self.currentID = [WDTeacher sharedUser].teacherID;
        self.currentKey = @"userID";
        self.currentMethod = @"getDKJSKBList";
        [self refreshDataWithparamKey:self.currentKey ID:self.currentID andMethod:self.currentMethod isSQL:YES];
        [self hiddenSchedulerView];
        [self.titleBtn setTitle:NSLocalizedString(@"我的课表", nil) forState:UIControlStateNormal];
        self.isMySchedule = true;
        [self.navigationItem.titleView sizeToFit];
        return;
    }
    self.isMySchedule = false;
    self.currentID =anyData[@"bjID"];
    self.currentKey = @"bjIDList";
    self.currentMethod = @"getBJKBList";
    [self.titleBtn setTitle:anyData[@"bjmc"] forState:UIControlStateNormal];
    [self.navigationItem.titleView sizeToFit];
    [self refreshDataWithparamKey:self.currentKey ID:self.currentID andMethod:self.currentMethod isSQL:YES];
    [self hiddenSchedulerView];
}

- (void)refreshDataWithparamKey:(NSString *)key ID:(NSString *)ID andMethod:(NSString *)method isSQL:(BOOL)isSQL {
    
    self.promptV.backgroundColor = self.rightTableV.backgroundColor;
    [self.promptV setPromtVWithHidden:NO isAnimation:YES activityHidden:NO promtStr:NSLocalizedString(@"加载中...", nil)];

    if (self.isScheduler) {
        self.promptV.backgroundColor = [UIColor clearColor];
        self.promptV.promptMessage = @"";
        self.isScheduler = NO;
    }
    NSArray *time = [self getDateForTitleDate];
    NSIndexPath *index = [self.leftTableV indexPathForSelectedRow];
    NSString *dateStr = [NSString stringWithFormat:@"%02ld%02ld%02ld",(long)[time[0] integerValue],(long)[time[1] integerValue],index.row + 1];
    
    //获取rightTableView数据
    [[WDCourse alloc] loadCourseDescriptionWithDateStr:dateStr ID:ID paramKey:key method:method isSQL:isSQL finished:^(NSArray *cc) {
        if (cc) {
            if (cc.count == 0) {
                [self.promptV setPromtVWithHidden:NO isAnimation:NO activityHidden:YES promtStr:NSLocalizedString(@"没有更多数据了~~", nil)];
                self.courseArray = cc;
                [self.rightTableV reloadData];
                if (self.rightTableV.visibleCells.count > 0) {
                    [self.rightTableV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
                }
                return ;
            }
            self.promptV.hidden = YES;
            self.courseArray = cc;
            [self.rightTableV reloadData];
            if (self.rightTableV.visibleCells.count > 0) {
                [self.rightTableV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
            }
            return ;
        }
        
        self.promptImageView.hidden = NO;
    }];
}

# pragma mark 懒加载
- (NSDictionary *)dayDict{
    return @{
             @"2" : NSLocalizedString(@"星期一", nil),
             @"3" : NSLocalizedString(@"星期二", nil),
             @"4" : NSLocalizedString(@"星期三", nil),
             @"5" : NSLocalizedString(@"星期四", nil),
             @"6" : NSLocalizedString(@"星期五", nil),
             @"7" : NSLocalizedString(@"星期六", nil),
             @"1" : NSLocalizedString(@"星期日", nil),
             };
}

- (WDSchedulerView *)schedulerView {
    if (!_schedulerView) {
      _schedulerView = [[[NSBundle mainBundle]loadNibNamed:@"WDSchedulerView" owner:nil options:nil] lastObject];
        [self.view addSubview:_schedulerView];
        CGFloat height = [WDSchedulerView getHeight];
        [_schedulerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(100);
            make.right.offset(-100);
            make.top.offset(64-height);
            make.height.equalTo(@(height));
        }];
        WEAKSELF(self);
        _schedulerView.clickedBlock = ^(NSDictionary *dict) {
            [weakSelf schedulerForClassesData:dict];
        };
        _schedulerView.hidden = YES;
    }
    return _schedulerView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        [self.view addSubview:_backView];
        [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenSchedulerView)]];
        _backView.hidden = YES;
    }
    return  _backView;
}

- (UITableView *)leftTableV {
    
    if (!_leftTableV) {
        UITableView *leftTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dateView.frame), 60, self.view.frame.size.height - CGRectGetMaxY(self.dateView.frame))];
        leftTable.dataSource = self;
        leftTable.delegate = self;
        leftTable.rowHeight = 60;
        leftTable.separatorStyle = NO;
        leftTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _leftTableV = leftTable;
        [self.view addSubview:_leftTableV];
    }
    return _leftTableV;
}

- (UITableView *)rightTableV {

    if (!_rightTableV) {
        UITableView *rightTable = [[UITableView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(self.dateView.frame), self.view.frame.size.width - CGRectGetMaxX(self.leftTableV.frame), self.view.frame.size.height - CGRectGetMaxY(self.dateView.frame)) style:UITableViewStyleGrouped];
        rightTable.dataSource = self;
        rightTable.delegate = self;
        rightTable.sectionFooterHeight = 0;
        rightTable.rowHeight = 65;
        rightTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        [rightTable registerClass:[ScheduleTableViewCell class] forCellReuseIdentifier:@"ScheduleTableViewCell"];
        _rightTableV = rightTable;
    }
    return _rightTableV;
}

- (WDPromptView *)promptV {
    if (!_promptV) {
        _promptV = [WDPromptView promptView];
        _promptV.frame = CGRectMake(60, CGRectGetMaxY(self.dateView.frame), CURRENT_DEVICE_SIZE.width - 60, CURRENT_DEVICE_SIZE.height - CGRectGetMaxY(self.dateView.frame) - 44);
        _promptV.activityView.color = [UIColor blackColor];
        [self.view addSubview:_promptV];
    }
    return _promptV;
}

- (WDPromptImageView *)promptImageView{
    if (!_promptImageView) {
        _promptImageView = [WDPromptImageView promptImageView];
        _promptImageView.frame = CGRectMake(60, CGRectGetMaxY(self.dateView.frame), CURRENT_DEVICE_SIZE.width - 60, CURRENT_DEVICE_SIZE.height - CGRectGetMaxY(self.dateView.frame) - 44);
        [self.view addSubview:_promptImageView];
    }
    return _promptImageView;
}

- (void)dealloc {
    [_promptV removeFromSuperview];
}

@end
