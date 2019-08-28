//
//  HWPractiveBaseViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPractiveBaseViewController.h"
#import "WDHTTPManager.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "HomeworkTaskInfoCell.h"
#import "HomeworkTaskView.h"
#import "HomeworkTaskModel.h"
#import "HWTitleNavView.h"
#import "HWSelectTestView.h"
#import "HWOnlineRequest.h"
#import "StudentModel.h"
#import "HWTaskModel.h"
#import "HWTextLeftLabel.h"
#import "HWOnlineNavView.h"

@interface HWPractiveBaseViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
///  提示label
@property (nonatomic, strong) UILabel *promptLabel;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *taskViews;
///  标题导航
@property (nonatomic, strong) HWTitleNavView *titleNav;
///  底部view
@property (nonatomic, strong) UIView *bottomView;
///  输入得分
@property (nonatomic, strong) UITextField *textField;
///  评分
@property (nonatomic, strong) UIButton *gradeButton;
///  是否是预习作业
@property (nonatomic, assign) BOOL isProview;

@property (nonatomic, assign) NSInteger currentIndex;
///  左边的view
@property (nonatomic, strong) HWTextLeftLabel *leftTextLabel;
///  是否是综合题
@property (nonatomic, assign) BOOL isSynthesisTest;

@end

@implementation HWPractiveBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

- (void)initView {
    self.promptLabel = [UILabel labelBackgroundColor:nil textColor:nil font:[UIFont systemFontOfSize:15] alpha:1];
    [self.view addSubview:self.promptLabel];
    self.promptLabel.text = NSLocalizedString(@"没有更多内容了", nil);
    self.promptLabel.alpha = 1;
    [self.promptLabel zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.view size:CGSizeZero offset:CGPointZero];
}

- (void)setStudentId:(NSString *)studentId {
    _studentId = studentId;
    [self fetchPublicBasePracticeWith:self.testId withId:self.studentId];
}

///  获取基础练习id
- (void)fetchPublicBasePracticeWith:(NSString *)ID withId:(NSString *)studentId {
    WEAKSELF(self);
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/kc!getSTXX.action"];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"yxxxID" : ID, @"userID" : studentId ? studentId : @""} urlString:url finished:^(NSDictionary *dict) {
        if (dict != nil ) {
            if ([dict[@"stList"] count] > 0) {
                [weakSelf initView1];
                weakSelf.isProview = true;
                [weakSelf setupCollectionView];
                [weakSelf showTaskInfoWithList:dict[@"stList"]];
            } else {
                weakSelf.promptLabel.alpha = 1;
            }
        }
    }];
}

- (void)initView1 {
    self.titleNav = [HWTitleNavView new];
    [self.view addSubview:self.titleNav];
    [self.titleNav.topicNavButton addTarget:self action:@selector(changeTestQuestionWith:) forControlEvents:UIControlEventTouchUpInside];
    self.titleNav.alpha = 1.0;
    self.titleNav.currentTitleLabel.text = @"1";
    self.titleNav.countTitleLabel.text = [NSString stringWithFormat:@"/%tu", self.taskViews.count];
    [self.view addSubview:self.collectionView];
    
    if (!self.isProview) {
        self.bottomView = [UIView viewWithBackground:[UIColor hex:0xF4F4F4 alpha:1.0] alpha:1.0];
        self.textField = [UITextField textFieldBackgroundColor:[UIColor whiteColor] placeholder:NSLocalizedString(@"请输入得分", nil) keyboardType:UIKeyboardTypeNumbersAndPunctuation];
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.leftTextLabel = [HWTextLeftLabel new];
        self.leftTextLabel.backgroundColor = [UIColor clearColor];
        self.leftTextLabel.textColor = [UIColor blackColor];
        self.leftTextLabel.font = [UIFont systemFontOfSize:16];
        self.leftTextLabel.bounds = CGRectMake(3, 0, 15, 15);
        self.leftTextLabel.adjustsFontSizeToFitWidth = true;
        self.textField.leftView = self.leftTextLabel;
        self.textField.leftViewMode = UITextFieldViewModeAlways;
        
        self.gradeButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:NSLocalizedString(@"评分", nil) titleColor:[UIColor whiteColor] backgroundColor:[UIColor hex:0x2F9B8C alpha:1.0]];
        self.gradeButton.layer.cornerRadius = 3;
        
        [self.view addSubview:self.bottomView];
        [self.bottomView addSubview:self.textField];
        [self.bottomView addSubview:self.gradeButton];
        
        [self.gradeButton addTarget:self action:@selector(scoreAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)initAutoLayout {
    [self.titleNav zk_AlignInner:ZK_AlignTypeTopLeft referView:self.view size:CGSizeMake([UIScreen wd_screenWidth], 40) offset:CGPointMake(0, 0)];
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsMake(40, 0, 0, 0)];
    [self.bottomView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.view size:CGSizeMake([UIScreen wd_screenWidth], 50) offset:CGPointMake(0, [UIScreen wd_screenHeight] - 50 - 64)];
    [self.textField zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.bottomView size:CGSizeMake([UIScreen wd_screenWidth] - 100, 30) offset:CGPointMake(10, -10)];
    [self.gradeButton zk_AlignInner:ZK_AlignTypeBottomRight referView:self.bottomView size:CGSizeMake(70, 30) offset:CGPointMake(-10, -10)];
}

- (void)changeTestQuestionWith:(UIButton *)sender {
    WEAKSELF(self);
    NSInteger index = [self.titleNav.currentTitleLabel.text integerValue] - 1;
    [HWSelectTestView showSelectTestViewWith:self.view count:self.taskViews.count currentIndex:index didSel:^(NSInteger row) {
        [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:false];
    }];
    
}

- (void)showTaskInfoWithList:(NSArray *)stList {
    [self.taskViews removeAllObjects];
    int i = 0;
    for (NSDictionary *dict in stList) {
        HomeworkTaskModel *info = [HomeworkTaskModel practiceTaskModelWithDict:dict];
        info.isPreviewTask = self.isProview;
        HomeworkTaskView *taskView = [HomeworkTaskView taskViewWithContentInfo:info];
        if ([info.stlx isEqualToString:@"06"]) {
            for (HomeworkTaskModel *item in info.stxtList) {
                item.isPreviewTask = self.isProview;
                item.isSubmit = self.isSubmit;
            }
        }
        taskView.isEdit = NO;
        [taskView setupSubCell];
        if (self.isSubmit) {
            [taskView setupAnalysisCell];
            [taskView insertAnswerToTask];
        }
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
    taskView.leftTextLabel = self.leftTextLabel;
    self.currentIndex = indexPath.row;
    self.textField.text = taskView.info.mystdf;
    if ([taskView.info.stlx isEqualToString:@"06"]) { // 综合题
        self.isSynthesisTest = true;
    } else { // 普通题
        self.isSynthesisTest = false;
        self.leftTextLabel.text = @"";
    }
    
    
    [cell.contentView addSubview:taskView];
    [taskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int currentIndex = (self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
    if (self.taskViews.count > 0) {
        self.titleNav.currentTitleLabel.text = [NSString stringWithFormat:@"%tu", currentIndex + 1];
    }
}

- (NSMutableArray *)taskViews {
    if (!_taskViews) {
        _taskViews = [NSMutableArray array];
    }
    return _taskViews;
}

@end
