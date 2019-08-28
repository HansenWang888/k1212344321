//
//  HomeworkTaskInfoVC.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HomeworkTaskInfoVC.h"
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

@interface HomeworkTaskInfoVC ()<UICollectionViewDataSource,UICollectionViewDelegate>

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
///  是否提交
@property (nonatomic, assign) BOOL isSubmit;

@end

@implementation HomeworkTaskInfoVC

+ (instancetype)taskInfoWithList:(NSArray *)stList with:(BOOL)isPreview isSubmit:(BOOL)isSubmit {
    HomeworkTaskInfoVC *vc = [HomeworkTaskInfoVC new];
    vc.isSubmit = isSubmit;
    vc.isProview = isPreview;
    [vc setupCollectionView];
    [vc showTaskInfoWithList:stList];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initAutoLayout];
    self.automaticallyAdjustsScrollViewInsets = false;
}

- (void)initView {
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

///  评分方法
- (void)scoreAction {
    HomeworkTaskView *taskView = self.taskViews[self.currentIndex];
    [self.textField endEditing:false];
    [HWOnlineRequest onlineTaskScoreWith:self.student.id fbdxId:self.taskModel.fbdxID zyId:self.taskModel.zyID sjId:taskView.info.sjID ? taskView.info.sjID : @"" stId:taskView.info.stID xtId:self.isSynthesisTest ? self.leftTextLabel.ID : @"" stpf:self.textField.text handler:^(BOOL isSuccess) {
        if (isSuccess) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"批改成功", nil)];
            HomeworkTaskView *taskView = self.taskViews[self.currentIndex];
            if (self.isSynthesisTest) {
                taskView.info.stxtList[self.leftTextLabel.tag - 1].mystdf = self.textField.text;
                [taskView insertanalysisScore];
            } else {
                taskView.info.mystdf = self.textField.text;
                [taskView insertanalysisScore];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"批改失败", nil)];
        }
    }];
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
        if ([dict[@"stlx"] isEqualToString:@"06"]) {
            for (NSDictionary *item in dict[@"stnr"][@"xtList"]) {
                
            }
        }
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
