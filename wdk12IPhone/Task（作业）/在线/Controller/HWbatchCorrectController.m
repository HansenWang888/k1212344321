//
//  HWbatchCorrectController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWbatchCorrectController.h"
#import "HWAnswerDetailController.h"
#import "HomeworkTaskInfoVC.h"
#import "HWStudentListView.h"
#import "HWTitleNavView.h"
#import "HWOnlineRequest.h"
#import "HWSelectTestView.h"
#import "HomeworkTaskModel.h"
#import "HomeworkTaskView.h"
#import "HomeworkTaskInfoVC.h"
#import "OnlineTaskOtherSubjectView.h"
#import "HomeworkTaskInfoCell.h"
#import "HWOnlineTaskModel.h"
#import "HWQuestionPaper.h"
#import "HWOnlineNavView.h"
#import "StudentModel.h"
#import "HWDragView.h"
#import "Homework06View.h"

@interface HWbatchCorrectController ()<UICollectionViewDelegate, UICollectionViewDataSource>


@property (nonatomic, strong) HWStudentListView *dragListView;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *taskViews;
///  其他科目view
@property (nonatomic, strong) OnlineTaskOtherSubjectView *otherSubjectView;
///  其他练习高度
@property (nonatomic, assign) CGFloat otherHeight;
///  遮罩按钮
@property (nonatomic, strong) UIButton *maskButton;
///  当前试卷
@property (nonatomic, strong) HWQuestionPaper *currentSj;
///  试题试卷缓存
@property (nonatomic, strong) NSMutableDictionary *sjCacheM;
///  试卷答案缓存
@property (nonatomic, strong) NSMutableDictionary *sjAnswerM;
///  试题数据
@property (nonatomic, strong) NSArray *stData;
///  标题按钮
@property (nonatomic, strong) UIButton *titleButton;
///  切换试题数据源
@property (nonatomic, strong) HWOnlineTaskModel *testData;
/// 打开导航按钮
@property (nonatomic, strong) UIButton *openNavButton;
///  主观题数组
@property (nonatomic, strong) NSMutableArray *subjectivityTestM;
///  学生答案数据
@property (nonatomic, strong) NSMutableDictionary *studentData;
///  当前选择的小题索引
@property (nonatomic, assign) NSInteger currentSelXT;

@end

@implementation HWbatchCorrectController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self initView];
    [self initAutoLayout];
    [self initDragListView];
    [self loadData];
    [self initOtherSubjectView];
}

- (void)initOtherSubjectView {
    
    self.maskButton = [UIButton new];
    self.maskButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.maskButton.alpha = 0.0;
    [self.maskButton addTarget:self action:@selector(dismissOtherSJAction) forControlEvents:UIControlEventTouchUpInside];    
    self.otherSubjectView = [OnlineTaskOtherSubjectView new];
    [self.view addSubview:self.maskButton];
    [self.view addSubview:self.otherSubjectView];
    self.maskButton.frame = [UIScreen mainScreen].bounds;
    // 切换试卷内容方法
    WEAKSELF(self);
    self.otherSubjectView.didSelectCellBlock = ^ (HWQuestionPaper *sjdata) {
        weakSelf.currentSj = sjdata;
        if (weakSelf.sjCacheM[sjdata.sjID]) {
            weakSelf.stData = weakSelf.sjCacheM[sjdata.sjID];
            [weakSelf loadAnswer];
            [weakSelf.titleButton setTitle:[NSString stringWithFormat:@"%@ %@", sjdata.sjMC, @"\U0000e65e"] forState:UIControlStateNormal];
            [weakSelf dismissOtherSJAction];
            return ;
        }
        [HWOnlineRequest fetchPublicOnlineTaskQuestionPaperDataWith:sjdata.sjID handler:^(NSArray *data) {
            weakSelf.stData = data;
            weakSelf.sjCacheM[sjdata.sjID] = data;
            [weakSelf loadAnswer];
            [weakSelf dismissOtherSJAction];
        }];
    };
}

- (void)initView {
    
    self.titleButton = [UIButton buttonWithFont:[UIFont fontWithName:@"iconfont" size:17] title:[NSString stringWithFormat:@"%@ \U0000e65e", self.taskModel.zymc] titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor]];
    self.titleButton.bounds = CGRectMake(0, 0, 200, 20);
    self.navigationItem.titleView = self.titleButton;
    [self.titleButton addTarget:self action:@selector(showOtherSJAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.collectionView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.taskModel.zymc;
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.openNavButton = [UIButton buttonWithImageName:@"hw_title_nav" title:@"" font:nil titleColor:nil];
    [self.openNavButton addTarget:self action:@selector(changeTestQuestionAction) forControlEvents:UIControlEventTouchUpInside];
    self.openNavButton.frame = CGRectMake(0, 0, 22, 22);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.openNavButton];
}

- (void)initDragListView {
    self.dragListView = [HWStudentListView new];
    self.dragListView.taskModel = self.taskModel;
    [self.view addSubview:self.dragListView];
    NSArray *cons = [self.dragListView zk_AlignInner:ZK_AlignTypeBottomCenter referView:self.view size:CGSizeMake([UIScreen mainScreen].bounds.size.width, 60) offset:CGPointZero];
    NSLayoutConstraint *h = [self.dragListView zk_Constraint:cons attribute:NSLayoutAttributeHeight];
    self.dragListView.dragView.h = h;
    self.dragListView.backgroundColor = [UIColor clearColor];
    WEAKSELF(self);
    self.dragListView.didSelect = ^(NSIndexPath *index) {
        
        NSIndexPath *indexPath = [weakSelf.collectionView indexPathForCell:weakSelf.collectionView.visibleCells.firstObject];
        HomeworkTaskView *taskView = weakSelf.taskViews[indexPath.row];
        if ([taskView.info.stlx isEqualToString:@"0101"] || [taskView.info.stlx isEqualToString:@"0102"] || [taskView.info.stlx isEqualToString:@"03"]) {
            return ;
        }
        BOOL isXt = false; // 是否是小题
        if ([taskView.info.stlx isEqualToString:@"06"]) { // 找小题
            isXt = true;
            for (HomeworkTaskModel *item in taskView.info.stxtList) {
                if ([item.stlx isEqualToString:@"0101"] || [item.stlx isEqualToString:@"0102"] || [item.stlx isEqualToString:@"03"]) {
                    return ;
                }
            }
        }
        StudentModel *st = weakSelf.data[index.row];
        HWAnswerDetailController *detailVC = [HWAnswerDetailController new]; // 找到答案
        detailVC.taskModel = weakSelf.taskModel;
        
        NSString *sjId = [weakSelf.currentSj.sjID isEqualToString:@"-0"] ? @"" : weakSelf.currentSj.sjID;
        NSString *xtId = isXt ? (taskView.info.stxtList[weakSelf.currentSelXT].stID ? taskView.info.stxtList[weakSelf.currentSelXT].stID : @"") : @"";
        
        detailVC.gradeContent = ^(NSDictionary *dict) {
            if (isXt) {
                for (NSDictionary *item in st.snwerArray) {
                    if ([item[@"xtID"] isEqualToString:dict[@"xtID"]]) {
                        NSInteger i = [st.snwerArray indexOfObject:item];
                        [st.snwerArray removeObjectAtIndex:i];
                        [st.snwerArray addObject:dict];
                        [weakSelf.dragListView.tableView reloadData];
                        break;
                    }
                }
            } else {
                for (NSDictionary *item in st.snwerArray) {
                    if ([item[@"stID"] isEqualToString:dict[@"stID"]]) {
                        NSInteger i = [st.snwerArray indexOfObject:item];
                        [st.snwerArray removeObjectAtIndex:i];
                        [st.snwerArray addObject:dict];
                        [weakSelf.dragListView.tableView reloadData];
                        break;
                    }
                }
            }
        };
        
        [detailVC setValueForDataSourceWith:sjId type:isXt student:st stId:taskView.info.stID xtId:xtId];
        [weakSelf.navigationController pushViewController:detailVC animated:true];
    };
}

- (void)initAutoLayout {
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)changeTestQuestionAction {
    if (self.collectionView.visibleCells.count > 0) {
        UICollectionViewCell *cell = self.collectionView.visibleCells[0];
        HWOnlineNavView *navView = [HWOnlineNavView showNavViewActionWithCount:self.taskViews.count index:[self.collectionView indexPathForCell:cell].row count:self.subjectivityTestM];
        WEAKSELF(self);
        navView.didSelect = ^(NSInteger index) {
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
        };
    }
}

///  关闭选择其他试卷方法
- (void)dismissOtherSJAction {
    [self showOtherSJAction:self.titleButton];
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


- (void)showTaskInfoWithList:(NSArray *)stList {
    [self.taskViews removeAllObjects];
    int i = 0;
    for (NSDictionary *dict in stList) {
        HomeworkTaskModel *info = [HomeworkTaskModel taskModelWithDict:dict];
        HomeworkTaskView *taskView = [HomeworkTaskView taskViewWithContentInfo:info];
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

- (void)setupCollectionView {
    UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    flow.sectionInset = UIEdgeInsetsZero;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    self.collectionView.dataSource= self;
    self.collectionView.delegate = self;
    self.taskViews = @[].mutableCopy;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[HomeworkTaskInfoCell class] forCellWithReuseIdentifier:@"taskCell"];
    self.collectionView.bounces = YES;
    self.collectionView.pagingEnabled = YES;
    self.taskViews = @[].mutableCopy;
}

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
    self.currentSelXT = 0;
    HomeworkTaskInfoCell *cell = self.collectionView.visibleCells.firstObject;
    NSIndexPath *index = [self.collectionView indexPathForCell:cell];
    if (self.taskViews.count == 0) {
        return ;
    }
    Homework06View *v = self.taskViews[index.row];
    if ([v isKindOfClass:[Homework06View class]]) {
        v.tempCell.shadeView.backgroundColor = [UIColor clearColor];
    }
    [self setStudentShowData];
}

///  设置学生显示数据
- (void)setStudentShowData {
    
    HomeworkTaskInfoCell *cell = self.collectionView.visibleCells.firstObject;
    NSIndexPath *index = [self.collectionView indexPathForCell:cell];
    if (self.taskViews.count == 0) {
        return ;
    }
    HomeworkTaskView *v = self.taskViews[index.row];
    if ([v isKindOfClass:[Homework06View class]]) {
        WEAKSELF(self);
        ((Homework06View *)v).didSel = ^(NSIndexPath *index) {
            weakSelf.currentSelXT = index.row - 1;
        };
    }
    if (self.currentSelXT < 0) {
        return ;
    }
    BOOL type = false;
    NSString *stID = @"";
    if ([v.info.stlx isEqualToString:@"06"]) { // 综合题
        type = true;
        stID = v.info.stxtList[self.currentSelXT].stID;
    } else { // 普通题
        stID = v.info.stID;
    }
    
    [self.dragListView setValueForDataSource:self.data type:type xtIndex:self.currentSelXT stID:stID];
}

///  加载数据
- (void)loadData {
    WEAKSELF(self);
    [HWOnlineRequest fetchOnlineTaskPatternContent:self.taskModel.zyID handler:^(HWOnlineTaskModel *model) {
        weakSelf.testData = model;
        [weakSelf loadAnswer];
    }];
}

- (void)setCurrentSelXT:(NSInteger)currentSelXT {
    _currentSelXT = currentSelXT;
    if (currentSelXT < 0) {
        return ;
    }
    [self setStudentShowData];
}

///  加载答案
- (void)loadAnswer {
    WEAKSELF(self);
    [HWOnlineRequest fetchOnlineTaskFeedbackWith:self.taskModel.zyID sjId:[self.currentSj.sjID isEqualToString:@"-0"] ? @"" : self.currentSj.sjID fbdxlx:self.taskModel.fbdxlx fbdxId:self.taskModel.fbdxID handler:^(NSArray *data) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        for (NSDictionary *item in data) {
            dictM[item[@"xsID"]] = item;
        }
        weakSelf.studentData = dictM;
    }];
}

///  试题试卷切换数据源
- (void)setTestData:(HWOnlineTaskModel *)testData {
    _testData = testData;
    
    self.stData = testData.stList;
    HWQuestionPaper *obj = [HWQuestionPaper new];
    obj.sjMC = NSLocalizedString(@"试题", nil);
    obj.sjID = @"-0";
    self.sjCacheM[obj.sjID] = testData.stList;
    self.otherHeight = 40 * testData.sjList.count > 500 ? 500 : 40 * testData.sjList.count;
    self.otherSubjectView.frame = CGRectMake(0, -self.otherHeight, [UIScreen wd_screenWidth], self.otherHeight);
    if (testData.stList.count > 0) { // 如果是试题
        [self.titleButton setTitle:NSLocalizedString(@"试题", nil) forState:UIControlStateNormal];
    } else {
        self.otherSubjectView.dataSource = testData.sjList;
        self.currentSj = testData.sjList.firstObject;
        WEAKSELF(self);
        [HWOnlineRequest fetchPublicOnlineTaskQuestionPaperDataWith:self.currentSj.sjID handler:^(NSArray *data) {
            weakSelf.stData = data;
            weakSelf.sjCacheM[self.currentSj.sjID] = data;
            [weakSelf loadAnswer];
            if (testData.sjList.count > 1) {
                [weakSelf.titleButton setTitle:[NSString stringWithFormat:@"%@ %@", weakSelf.currentSj.sjMC, @"\U0000e65e"] forState:UIControlStateNormal];
            } else {
                [weakSelf.titleButton setTitle:weakSelf.currentSj.sjMC forState:UIControlStateNormal];
            }
        }];
    }
    
}

///  试题数据set方法
- (void)setStData:(NSArray *)stData {
    _stData = stData;
    [self showTaskInfoWithList:stData];
    [self.subjectivityTestM removeAllObjects];
    BOOL isObjectiveTest = false; // 是否是客观题
    NSInteger index = 0;
    NSInteger i = 0;
    for (NSDictionary *stItem in self.stData) { // 遍历试题
        
        if ([stItem[@"tmlx"] intValue] == 6) { // 小题
            NSArray *xtArray = stItem[@"stnr"][@"stxtList"];
            for (NSDictionary *xtItem in xtArray) { // 遍历小题
                if ([xtItem[@"xtlx"] isEqualToString:@"02"] || [xtItem[@"xtlx"] isEqualToString:@"05"]) {// ========> 判断主观题
                    isObjectiveTest = true;
                    [self.subjectivityTestM addObject:[NSString stringWithFormat:@"%tu", i + 1]];
                }
            }
        } else { // 其他题
            if ([stItem[@"tmlx"] isEqualToString:@"02"] || [stItem[@"tmlx"] isEqualToString:@"05"]) { // 主观题
                isObjectiveTest = true;
                [self.subjectivityTestM addObject:[NSString stringWithFormat:@"%tu", i + 1]];
            }
        }
        if (!isObjectiveTest) {
            index += 1;
        }
        i++;
    }
    if (isObjectiveTest) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    }
}

- (void)setStudentData:(NSMutableDictionary *)studentData {
    _studentData = studentData;
    
    for (StudentModel *item in self.data) {
        if (studentData[item.id]) {
            item.snwerArray = [NSMutableArray arrayWithArray:studentData[item.id][@"daanfk"]];
        }
    }
    [self setStudentShowData];
}

///  试题view
- (NSMutableArray *)taskViews {
    if (!_taskViews) {
        _taskViews = [NSMutableArray array];
    }
    return _taskViews;
}

///  试卷作业缓存
- (NSMutableDictionary *)sjCacheM {
    if (!_sjCacheM) {
        _sjCacheM = [NSMutableDictionary dictionary];
    }
    return _sjCacheM;
}

///  主观题数组
- (NSMutableArray *)subjectivityTestM {
    if (!_subjectivityTestM) {
        _subjectivityTestM = [NSMutableArray array];
    }
    return _subjectivityTestM;
}

@end
