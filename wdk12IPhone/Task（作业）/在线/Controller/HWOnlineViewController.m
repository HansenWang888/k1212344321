//
//  HWOnlineViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWOnlineViewController.h"
#import "OnlineTaskOtherSubjectView.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "HomeworkTaskInfoVC.h"
#import "HWOnlineRequest.h"
#import "HWOnlineTaskModel.h"
#import "HWQuestionPaper.h"
#import "HWTaskModel.h"
#import "StudentModel.h"
#import "HomeworkTaskModel.h"
#import "HomeworkTaskView.h"
#import "HWTitleNavView.h"
#import "HWSelectTestView.h"
#import "HWOnlineNavView.h"
#import "HomeworkTaskInfoCell.h"
#import "Homework06View.h"

@interface HWOnlineViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) HomeworkTaskInfoVC *taskvc;
///  切换试题数据源
@property (nonatomic, strong) HWOnlineTaskModel *testData;

@property (nonatomic, strong) UIButton *titleButton;
///  遮罩按钮
@property (nonatomic, strong) UIButton *maskButton;
///  其他科目view
@property (nonatomic, strong) OnlineTaskOtherSubjectView *otherSubjectView;
///  其他练习高度
@property (nonatomic, assign) CGFloat otherHeight;
///  试题数据
@property (nonatomic, strong) NSArray *stData;
///  试题试卷缓存
@property (nonatomic, strong) NSMutableDictionary *sjCacheM;
///  试卷答案缓存
@property (nonatomic, strong) NSMutableDictionary *sjAnswerM;
///  当前试卷
@property (nonatomic, strong) HWQuestionPaper *currentSj;
///  当前答案
@property (nonatomic, strong) NSDictionary *currentAnswer;
/// 打开导航按钮
@property (nonatomic, strong) UIButton *openNavButton;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *taskViews;
///  底部view
@property (nonatomic, strong) UIView *bottomView;
///  输入得分
@property (nonatomic, strong) UITextField *textField;
///  评分
@property (nonatomic, strong) UIButton *gradeButton;
///  提交状态 1 已提交 2 未提交
@property (nonatomic, copy) NSString *submitStatus;
///  当前选择的数据源
@property (nonatomic, strong) HomeworkTaskModel *currentSelData;
///  当前选择的小题
@property (nonatomic, assign) NSInteger currentSelXT;
///  主观题数组
@property (nonatomic, strong) NSMutableArray *subjectivityTestM;

@property (nonatomic,assign) BOOL isGrading; //是否正在批改作业（正在调用接口）

@end

@implementation HWOnlineViewController

- (void)loadView {
    self.view = [TPKeyboardAvoidingScrollView new];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *scrollView = (UIScrollView *)self.view;
    scrollView.contentInset = UIEdgeInsetsZero;
    scrollView.contentSize = [UIScreen mainScreen].bounds.size;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTaskDetail];
    [self setupCollectionView];
    [self initView];
    [self initAutoLayout];
    [self initNav];
}

///  初始化导航
- (void)initNav {
    self.titleButton = [UIButton buttonWithFont:[UIFont fontWithName:@"iconfont" size:17] title:[NSString stringWithFormat:@"%@ \U0000e65e",NSLocalizedString(@"试题", nil)] titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor]];
    self.titleButton.bounds = CGRectMake(0, 0, 200, 20);
    self.navigationItem.titleView = self.titleButton;
    [self.titleButton addTarget:self action:@selector(showOtherSJAction:) forControlEvents:UIControlEventTouchUpInside];
    self.maskButton = [UIButton new];
    self.maskButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.maskButton.alpha = 0.0;
    [self.maskButton addTarget:self action:@selector(dismissOtherSJAction) forControlEvents:UIControlEventTouchUpInside];
    self.otherSubjectView = [OnlineTaskOtherSubjectView new];
    [self.view addSubview:self.maskButton];
    [self.view addSubview:self.otherSubjectView];
    self.maskButton.frame = [UIScreen mainScreen].bounds;
    self.openNavButton = [UIButton buttonWithImageName:@"hw_title_nav" title:@"" font:nil titleColor:nil];
    [self.openNavButton addTarget:self action:@selector(changeTestQuestionAction) forControlEvents:UIControlEventTouchUpInside];
    self.openNavButton.frame = CGRectMake(0, 0, 22, 22);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.openNavButton];
    
    // 切换试卷内容方法
    WEAKSELF(self);
    self.otherSubjectView.didSelectCellBlock = ^ (HWQuestionPaper *sjdata) {
        [weakSelf loadOtherSJWith:sjdata];
    };
}

- (void)loadOtherSJWith:(HWQuestionPaper *)sjdata {
    self.currentSj = sjdata;
    if (self.testData.sjList.count > 1) {
        [self.titleButton setTitle:[NSString stringWithFormat:@"%@ %@", sjdata.sjMC, @"\U0000e65e"] forState:UIControlStateNormal];
    } else {
        [self.titleButton setTitle:sjdata.sjMC forState:UIControlStateNormal];
    }
    if (self.sjCacheM[sjdata.sjID]) {
        self.stData = self.sjCacheM[sjdata.sjID];
        [self loadAnswer];
        [self dismissOtherSJAction];
        return ;
    }
    WEAKSELF(self);
    [HWOnlineRequest fetchPublicOnlineTaskQuestionPaperDataWith:sjdata.sjID handler:^(NSArray *data) {
        weakSelf.stData = data;
        weakSelf.sjCacheM[sjdata.sjID] = data;
        [weakSelf loadAnswer];
        weakSelf.titleButton.selected = true;
        [weakSelf dismissOtherSJAction];
    }];
}

///  初始化属性
- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.bottomView = [UIView viewWithBackground:[UIColor hex:0xF4F4F4 alpha:1.0] alpha:1.0];
    self.textField = [UITextField textFieldBackgroundColor:[UIColor whiteColor] placeholder:NSLocalizedString(@"请输入得分", nil) keyboardType:UIKeyboardTypeDecimalPad];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    self.gradeButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"评分", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x2F9B8C alpha:1.0]];
    self.gradeButton.layer.cornerRadius = 3;
    [self.gradeButton addTarget:self action:@selector(correctTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.textField];
    [self.bottomView addSubview:self.gradeButton];
}

///  初始化collectionView
- (void)setupCollectionView {
    self.layout = [UICollectionViewFlowLayout new];
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    self.layout.sectionInset = UIEdgeInsetsZero;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.dataSource= self;
    self.collectionView.delegate = self;
    self.taskViews = @[].mutableCopy;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[HomeworkTaskInfoCell class] forCellWithReuseIdentifier:@"taskCell"];
    self.collectionView.bounces = YES;
    self.collectionView.pagingEnabled = YES;
    self.taskViews = @[].mutableCopy;
}

///  初始化布局
- (void)initAutoLayout {
    [self.collectionView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.view size:CGSizeMake([UIScreen wd_screenWidth], [UIScreen wd_screenHeight] - 114) offset:CGPointMake(0, 64)];
    [self.bottomView zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.collectionView size:CGSizeMake([UIScreen wd_screenWidth], 50) offset:CGPointZero];
    [self.textField zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.bottomView size:CGSizeMake([UIScreen wd_screenWidth] - 100, 30) offset:CGPointMake(10, -10)];
    [self.gradeButton zk_AlignInner:ZK_AlignTypeBottomRight referView:self.bottomView size:CGSizeMake(70, 30) offset:CGPointMake(-10, -10)];
}

///  显示其他试卷方法
- (void)showOtherSJAction:(UIButton *)sender {
    if (self.testData.stList.count > 0 || self.testData.sjList.count == 1) { return ; }
    sender.selected = !sender.isSelected;
    [sender setTitle:[NSString stringWithFormat:@"%@ %@", self.currentSj.sjMC, !sender.selected ? @"\U0000e65e" : @"\U0000e613"] forState:UIControlStateNormal];

    CGFloat h = sender.selected ? self.otherHeight : 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.maskButton.alpha = sender.selected ? 1.0 : 0.0;
        self.otherSubjectView.frame = CGRectMake(0, 64, [UIScreen wd_screenWidth], h);
        [self.otherSubjectView layoutIfNeeded];
    }];
}

///  关闭选择其他试卷方法
- (void)dismissOtherSJAction {
    [self showOtherSJAction:self.titleButton];
}

///  加载作业内容
- (void)loadTaskDetail {
    WEAKSELF(self);
    [HWOnlineRequest fetchOnlineTaskPatternContent:self.taskModel.zyID handler:^(HWOnlineTaskModel *model) {
        weakSelf.testData = model;
        [weakSelf loadAnswer];
    }];
}

///  加载答案
- (void)loadAnswer {
    WEAKSELF(self);
    if (self.sjAnswerM[self.currentSj.sjID]) {
        self.currentAnswer = self.sjAnswerM[self.currentSj.sjID];
        return ;
    }
    [HWOnlineRequest fetchStudentAnswerContentWith:self.taskModel.zyID xsId:self.student.id fbdxId:self.taskModel.fbdxID sjId:([self.currentSj.sjID isEqualToString:@"-0"] ? @"" : self.currentSj.sjID) handler:^(NSDictionary *dict) {
        //        if (dict) {
        weakSelf.currentAnswer = dict;
        weakSelf.sjAnswerM[weakSelf.currentSj.sjID] = dict;
        //        }
    }];
}

///  试题试卷切换数据源
- (void)setTestData:(HWOnlineTaskModel *)testData {
    _testData = testData;
    self.stData = testData.stList;
    HWQuestionPaper *obj = [HWQuestionPaper new];
    obj.sjMC = NSLocalizedString(@"试题", nil);
    obj.sjID = @"-0";
    self.currentSj = obj;
    self.sjCacheM[obj.sjID] = testData.stList;
    self.otherHeight = 40 * testData.sjList.count > 500 ? 500 : 40 * testData.sjList.count;
    self.otherSubjectView.frame = CGRectMake(0, -self.otherHeight, [UIScreen wd_screenWidth], self.otherHeight);
    if (testData.stList.count > 0) { // 如果是试题
        [self.titleButton setTitle:NSLocalizedString(@"试题", nil) forState:UIControlStateNormal];
    } else {
        self.otherSubjectView.dataSource = testData.sjList;
        self.currentSj = testData.sjList.firstObject;
        [self loadOtherSJWith:testData.sjList.firstObject];
    }
}

///  切换现在的答案
- (void)setCurrentAnswer:(NSDictionary *)currentAnswer {
    _currentAnswer = currentAnswer;
    
    [self.subjectivityTestM removeAllObjects]; // 清除主观题数组
    self.submitStatus = currentAnswer[@"zt"];
    BOOL isObjectiveTest = false; // 是否是客观题
    NSInteger index = 0;
    NSInteger i = 0;
    NSArray *array = currentAnswer[@"daanfk"]; // 答案数组
    NSMutableArray *stArrayM = @[].mutableCopy; // 最终试题列表
    for (NSDictionary *stItem in self.stData) { // 遍历试题
        if ([stItem[@"tmlx"] intValue] == 6) { // 综合题
            NSMutableDictionary *stDictM = [NSMutableDictionary dictionaryWithDictionary:stItem]; // 试题
            // 遍历小题
            NSMutableArray *xtArrayM = [NSMutableArray array];
            NSMutableDictionary *xtDictM = [NSMutableDictionary dictionaryWithDictionary:stItem[@"stnr"]];
            NSArray *xtArray = stItem[@"stnr"][@"stxtList"];
            for (NSDictionary *xtItem in xtArray) { // 遍历小题
                NSMutableDictionary *stxtM = [NSMutableDictionary dictionaryWithDictionary:xtItem];
                for (NSDictionary *daItem in array) {   // 遍历答案
                    if ([xtItem[@"xtlx"] isEqualToString:@"02"] || [xtItem[@"xtlx"] isEqualToString:@"05"]) {// ========> 判断主观题
                        isObjectiveTest = true;
                        [self.subjectivityTestM addObject:[NSString stringWithFormat:@"%tu", i + 1]];
                    }
                    if ([daItem[@"xtID"] isEqualToString:xtItem[@"xtID"]]) {
                        stxtM[@"mystda"] = daItem[@"daannr"];
//                        if ([xtItem[@"xtlx"] isEqualToString:@"03"]) {
//                            stxtM[@"mystda"] = [daItem[@"daannr"] isEqualToString:@"1"] ? @"正确" : @"错误";
//                        }
                        
                        stxtM[@"mydasfzq"] = daItem[@"sfzq"];
                        stxtM[@"mystdf"] = [NSString stringWithFormat:@"%@", daItem[@"df"]];
                        continue;
                    }
                }
                [xtArrayM addObject:stxtM];
            }
            xtDictM[@"stxtList"] = xtArrayM;
            stDictM[@"stnr"] = xtDictM;
            [stArrayM addObject:stDictM];
        } else { // 非综合题
            if ([stItem[@"tmlx"] isEqualToString:@"02"] || [stItem[@"tmlx"] isEqualToString:@"05"]) { // ========> 判断主观题
                isObjectiveTest = true;
                [self.subjectivityTestM addObject:[NSString stringWithFormat:@"%tu", i + 1]];
            }
            NSMutableDictionary *stDictM = [NSMutableDictionary dictionaryWithDictionary:stItem]; // 试题
            for (NSDictionary *daItem in array) {   // 遍历答案
                if ([daItem[@"stID"] isEqualToString:stItem[@"stID"]]) {
                    stDictM[@"mystda"] = daItem[@"daannr"];
//                    if ([stItem[@"tmlx"] isEqualToString:@"03"]) {
//                        stDictM[@"mystda"] = [daItem[@"daannr"] isEqualToString:@"1"] ? @"正确" : @"错误";
//                    }
                    stDictM[@"mydasfzq"] = daItem[@"sfzq"];
                    stDictM[@"mystdf"] = daItem[@"df"];
                    continue;
                }
            }
            [stArrayM addObject:stDictM];
        }
        if (!isObjectiveTest) {
            index += 1;
        }
        i++;
    }
    if (![self.submitStatus isEqualToString:@"1"]) {
        isObjectiveTest = true;
    }
    
    if (isObjectiveTest) { //其中有主观题
        self.textField.placeholder = NSLocalizedString(@"请输入得分", nil);
        self.textField.enabled = true;
        self.textField.tag = 1;
    } else { // 都是客观题
        if (self.stData.count > 0) {
            self.textField.enabled = false;
            self.textField.placeholder = NSLocalizedString(@"无可批改题型,请直接评分", nil);
            self.textField.tag = 2;
        }
    }
    
    [self showTaskInfoWithList:stArrayM];
    if (isObjectiveTest) {
        if (self.collectionView.visibleCells.count > 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
        }
    }
    [self performSelector:@selector(setTextFieldStatus) withObject:self afterDelay:0.1];
}

///  批改作业方法
- (void)correctTaskAction {
    NSString *pf = [NSString stringWithFormat:@"%.2f", [self.textField.text floatValue]];
    NSLog(@"点了button==============> ");
    if (self.isGrading) return;

    if ([self.textField.text floatValue] > 100.0 || [self.textField.text floatValue] < 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"得分输入有误，请输入0-100以内的分数", nil)];
        return ;
    }
    WEAKSELF(self);
    self.isGrading = YES;
    if (self.textField.tag == 2) { // 没有可批改的题
        [HWOnlineRequest onlineTaskObjectiveScoreWith:self.taskModel.zyID fbdxId:self.taskModel.fbdxID xsId:self.student.id handler:^(BOOL isSuccess) {
            self.isGrading = NO;
            if (isSuccess) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"批改成功", nil)];
                if (weakSelf.correctFinish && ![weakSelf.submitStatus isEqualToString:@"2"]) {
                    weakSelf.correctFinish(weakSelf.student);
                }
                weakSelf.submitStatus = @"2";
                [weakSelf.textField endEditing:false];
                weakSelf.textField.text = @"";
            } else {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"批改失败,请稍候重试", nil)];
            }
        }];
    } else {
        
        NSString *sjID = [self.currentSj.sjID isEqualToString:@"-0"] ? @"" : self.currentSj.sjID;
//        NSString *xtID = [self.currentSelData.stlx isEqualToString:@"06"] ? self.currentSelData.stxtList[self.currentSelXT].stID : @"";
        
        NSString *stID = @"";
        NSString *xtID = @"";
        
        if ([self.currentSelData.pxbh rangeOfString:@"."].location != NSNotFound) {//综合体拆分出来的主观题
            stID = @"";
            xtID = self.currentSelData.stID;
        }else {
            stID = self.currentSelData.stID;
            xtID = @"";
        }
        
        [HWOnlineRequest onlineTaskScoreWith:self.student.id fbdxId:self.taskModel.fbdxID zyId:self.taskModel.zyID sjId:sjID stId:stID xtId:xtID stpf:pf handler:^(BOOL isSuccess) {
            self.isGrading = NO;
            if (isSuccess) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"批改成功", nil)];
                
                HomeworkTaskInfoCell *cell = self.collectionView.visibleCells.firstObject;
                NSIndexPath *index = [self.collectionView indexPathForCell:cell];
                HomeworkTaskView *v = self.taskViews[index.row];
                
                if ([v.info.stlx isEqualToString:@"06"]) {
                    v.info.stxtList[weakSelf.currentSelXT].mystdf = self.textField.text;
                    if ([v.info.stxtList[weakSelf.currentSelXT].stlx isEqualToString:@"02"] || [v.info.stxtList[weakSelf.currentSelXT].stlx isEqualToString:@"05"]) {
                        NSInteger fz = [v.info.stxtList[weakSelf.currentSelXT].fz integerValue];
                        NSInteger df = [v.info.stxtList[weakSelf.currentSelXT].mystdf integerValue];
                        v.info.stxtList[weakSelf.currentSelXT].mydasfzq = (fz <= df) ? @"1" : @"0";
                        [[v.subCells[weakSelf.currentSelXT + 1] taskView] insertanalysisScore];
//                        [v insertanalysisScore];
                    }
                } else {
                    v.info.mystdf = self.textField.text;
                    if ([v.info.stlx isEqualToString:@"02"] || [v.info.stlx isEqualToString:@"05"]) {
                        v.info.mydasfzq = ([v.info.fz integerValue] <= [v.info.mystdf integerValue]) ? @"1" : @"0";
                    }
                    [v insertanalysisScore];
                }
                if (weakSelf.correctFinish && ![weakSelf.submitStatus isEqualToString:@"2"]) {
                    weakSelf.correctFinish(weakSelf.student);
                    weakSelf.submitStatus = @"2";
                }
                [weakSelf.textField endEditing:false];
                weakSelf.textField.text = @"";
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"批改失败", nil)];
            }
        }];
    }
}

///  切换试题导航方法
- (void)changeTestQuestionAction {
    if (self.collectionView.visibleCells.count > 0) {
        NSMutableArray *temArr = @[].mutableCopy;
        for (HomeworkTaskView *item in self.taskViews) {
            [temArr addObject:item.info.pxbh];
        }
        UICollectionViewCell *cell = self.collectionView.visibleCells[0];
        HWOnlineNavView *navView = [HWOnlineNavView showNavViewActionWithCount:self.taskViews.count index:[self.collectionView indexPathForCell:cell].row count:self.subjectivityTestM titleArray:temArr];
        WEAKSELF(self);
        navView.didSelect = ^(NSInteger index) {
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:true];
            [weakSelf performSelector:@selector(setTextFieldStatus) withObject:self afterDelay:0.5];
        };
    }
}

- (void)showTaskInfoWithList:(NSArray *)stList {
    [self.taskViews removeAllObjects];
    
    NSMutableArray *mulArr = @[].mutableCopy;
    
    for (NSDictionary *item in stList) {
        if ([item[@"tmlx"] isEqualToString:@"06"]) {
            
            NSArray *temArr = item[@"stnr"][@"stxtList"];
            
            for (NSDictionary *dict in temArr) {
                HomeworkTaskModel *info = [HomeworkTaskModel task06ModelWithDict:dict];
                info.sttg = [NSString stringWithFormat:@"%@<br>%@", item[@"stnr"][@"sttg"], info.sttg];
                info.pxbh = [NSString stringWithFormat:@"%@.%@", item[@"pxbh"], info.pxbh];
                [mulArr addObject:info];
            }
        }else {
            HomeworkTaskModel *info = [HomeworkTaskModel taskModelWithDict:item];
            [mulArr addObject:info];
        }
    }
    
    int i = 0;
    WEAKSELF(self);
    for (HomeworkTaskModel *model in mulArr) {
        HomeworkTaskView *taskView = [HomeworkTaskView taskViewWithContentInfo:model];
        if ([taskView isKindOfClass:[Homework06View class]]) {
            Homework06View *tasV = (Homework06View *)taskView;
            tasV.didSel = ^(NSIndexPath *index) {
                weakSelf.currentSelXT = index.row - 1;
                if (tasV.info.stxtList[index.row - 1].mystda == nil) {
                    [self prohibitTextField];
                    self.textField.placeholder = NSLocalizedString(@"该题未作答，不能批改", nil);
                    return ;
                }

                if ([tasV.info.stxtList[index.row - 1].stlx isEqualToString:@"02"] || [tasV.info.stxtList[index.row - 1].stlx isEqualToString:@"05"]) { // 客观题
                    [weakSelf defaultTextFieldPlaceholder];
                } else {
                    [weakSelf prohibitTextField];
                }
                
            };
        }
        taskView.isFeedback = self.isFeedback;
//        taskView.tjzt = self.taskModel.ytjs
        taskView.isEdit = NO;
        [taskView setupSubCell];
        [taskView setupAnalysisCell];
        [taskView insertAnswerToTask];
        [self.taskViews addObject:taskView];
        i++;
    }
    
    //显示试题
    [self.collectionView reloadData];
}

- (void)setTextFieldStatus {
    
    if (([self.textField.placeholder isEqualToString:NSLocalizedString(@"无可批改题型,请直接评分", nil)])) {
        return ;
    }
    
    if (self.stData.count == 0) {
        [self prohibitTextField];
        return ;
    }

    HomeworkTaskInfoCell *cell = self.collectionView.visibleCells.firstObject;
    NSIndexPath *index = [self.collectionView indexPathForCell:cell];
    if (index.row >= self.taskViews.count) {
        return ;
    }
    HomeworkTaskView *v = self.taskViews[index.row];
    self.currentSelData = v.info;
    
    if (!v.info.mystda && ![v.info.stlx isEqualToString:@"06"]) {
        [self prohibitTextField];
        self.textField.placeholder = NSLocalizedString(@"该题未作答，不能批改", nil);
        return ;
    }
    
    if ([v.info.stlx isEqualToString:@"0101"] || [v.info.stlx isEqualToString:@"0102"] || [v.info.stlx isEqualToString:@"03"]) { // 客观题
        [self prohibitTextField];
    } else if ([v.info.stlx isEqualToString:@"06"]) { // 主观题
        for (HomeworkTaskModel *obj in v.info.stxtList) {
            if ([obj.stlx isEqualToString:@"02"] || [obj.stlx isEqualToString:@"05"]) { // 客观题
                [self defaultTextFieldPlaceholder];
                return ;
            }
        }
        [self prohibitTextField];
    } else if ([v.info.stlx isEqualToString:@"02"] || [v.info.stlx isEqualToString:@"05"]) {
        [self defaultTextFieldPlaceholder];
    }
}

///  禁用textfield
- (void)prohibitTextField {
    self.textField.enabled = false;
    self.gradeButton.enabled = false;
    self.textField.placeholder = NSLocalizedString(@"该题不能评分", nil);
}

///  默认textfield样式
- (void)defaultTextFieldPlaceholder {
    self.textField.enabled = true;
    self.gradeButton.enabled = true;
    self.textField.placeholder = NSLocalizedString(@"请输入得分", nil);
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.taskViews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeworkTaskInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"taskCell" forIndexPath:indexPath];
    HomeworkTaskView *taskView = self.taskViews[indexPath.row];
    
    [cell.contentView addSubview:taskView];
    [taskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - scrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setTextFieldStatus];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.textField endEditing:true];
}

///  试卷作业缓存
- (NSMutableDictionary *)sjCacheM {
    if (!_sjCacheM) {
        _sjCacheM = [NSMutableDictionary dictionary];
    }
    return _sjCacheM;
}

///  试卷答案缓存
- (NSMutableDictionary *)sjAnswerM {
    if (!_sjAnswerM) {
        _sjAnswerM = [NSMutableDictionary dictionary];
    }
    return _sjAnswerM;
}

///  作业view缓存
- (NSMutableArray *)taskViews {
    if (!_taskViews) {
        _taskViews = [NSMutableArray array];
    }
    return _taskViews;
}

///  主观题数组
- (NSMutableArray *)subjectivityTestM {
    if (!_subjectivityTestM) {
        _subjectivityTestM = [NSMutableArray array];
    }
    return _subjectivityTestM;
}

@end
