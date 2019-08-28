//
//  HWTaskCheckViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTaskCheckViewController.h"
#import "HWbatchCorrectController.h"
#import "HWStayCorrectController.h"
#import "HWAlreadyViewController.h"
#import "HWNotSubmitController.h"
#import "HWNotOnlineRequest.h"
#import "HWTaskListRequest.h"
#import "HWPhotographModel.h"
#import "HWOnlineRequest.h"
#import "HWTaskModel.h"

@interface HWTaskCheckViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

///  待批改控制器
@property (nonatomic, strong) HWStayCorrectController *scvc;
///  已批改控制器
@property (nonatomic, strong) HWAlreadyViewController *slvc;
///  未提交控制器
@property (nonatomic, strong) HWNotSubmitController *nsvc;
///  待批改按钮
@property (nonatomic, strong) UIButton *scButton;
///  已批改按钮
@property (nonatomic, strong) UIButton *slButton;
///  未提交按钮
@property (nonatomic, strong) UIButton *nsButton;
///  指示view
@property (nonatomic, strong) UIView *indicateView;
///  状态view
@property (nonatomic, strong) UIView *statusView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  非在线数据
@property (nonatomic, strong) HWStudentTask *notOnlineData;
///  在线学生数据
@property (nonatomic, copy) NSArray *studentData;
///  在线学生答案数据
@property (nonatomic, copy) NSArray *studentAnswerData;

@end

@implementation HWTaskCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self initNav];
    [self initView];
    [self initAutoLayout];
    [self loadData];
    [self loadTaskData];
}

//- (void)initNav {
//    if ([self.taskModel.zylx isEqualToString:@"2"]) { // 在线
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"按题批改", nil) style:UIBarButtonItemStylePlain target:self action:@selector(batchCorrectTaskAction)];
//    }
//}

///  批量批改作业方法
- (void)batchCorrectTaskAction {
    HWbatchCorrectController *vc = [HWbatchCorrectController new];
    vc.taskModel = self.taskModel;
    NSMutableArray *arrayM = [NSMutableArray arrayWithArray:self.studentData[0]];
    [arrayM addObjectsFromArray:self.studentData[1]];
    vc.data = arrayM.copy;
    vc.answerData = self.studentAnswerData;
    [self.navigationController pushViewController:vc animated:true];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    self.scvc = [HWStayCorrectController new];
    self.nsvc = [HWNotSubmitController new];
    
    [self addChildViewController:self.scvc];
    [self addChildViewController:self.nsvc];

    self.scvc.taskModel = self.taskModel;
    self.nsvc.taskModel = self.taskModel;
    
    self.statusView = [UIView new];
    self.scButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:15] title:NSLocalizedString(@"待批改", nil) titleColor:[UIColor blackColor] backgroundColor:nil];
    self.nsButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:15] title:NSLocalizedString(@"未提交", nil) titleColor:[UIColor blackColor] backgroundColor:nil];
    [self.scButton addTarget:self action:@selector(changeCurrentControllerWith:) forControlEvents:UIControlEventTouchUpInside];
    [self.nsButton addTarget:self action:@selector(changeCurrentControllerWith:) forControlEvents:UIControlEventTouchUpInside];
    self.scButton.tag = 0;
    self.nsButton.tag = ![self.taskModel.zylx isEqualToString:@""] ? 2 : 1;
    self.indicateView = [UIView viewWithBackground:[UIColor hex:0x349B8C alpha:1.0] alpha:1.0];
    
    [self.view addSubview:self.statusView];
    [self.statusView addSubview:self.scButton];

    if (![self.taskModel.zylx isEqualToString:@""]) { // 预习作业
        self.slvc = [HWAlreadyViewController new];
        [self addChildViewController:self.slvc];
        self.slvc.taskModel = self.taskModel;
        self.slButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:15] title:NSLocalizedString(@"已批改", nil) titleColor:[UIColor blackColor] backgroundColor:nil];
        [self.slButton addTarget:self action:@selector(changeCurrentControllerWith:) forControlEvents:UIControlEventTouchUpInside];
        self.slButton.tag = 1;
        [self.statusView addSubview:self.slButton];
        self.scvc.alreadyVC = self.slvc;
    }

    [self.statusView addSubview:self.nsButton];
    [self.statusView addSubview:self.indicateView];
    
    self.title = [NSString stringWithFormat:@"%@%@", self.taskModel.njmc, self.taskModel.fbdxmc];
    
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.itemSize = CGSizeMake([UIScreen wd_screenWidth], [UIScreen wd_screenHeight] - 64 - 35);
    self.collectionView.pagingEnabled = true;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
}

- (void)initAutoLayout {
    [self.statusView zk_AlignInner:ZK_AlignTypeTopLeft referView:self.view size:CGSizeMake([UIScreen wd_screenWidth], 35) offset:CGPointMake(0, 64)];
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsMake(64 + 35, 0, 0, 0)];
    if (![self.taskModel.zylx isEqualToString:@""]) {
        [self.scButton zk_AlignInner:ZK_AlignTypeCenterLeft referView:self.statusView size:CGSizeMake([UIScreen wd_screenWidth]/3, 17) offset:CGPointMake(0, 0)];
        [self.slButton zk_AlignInner:ZK_AlignTypeCenterCenter referView:self.statusView size:CGSizeMake([UIScreen wd_screenWidth]/3, 17) offset:CGPointMake(0, 0)];
        [self.nsButton zk_AlignInner:ZK_AlignTypeCenterRight referView:self.statusView size:CGSizeMake([UIScreen wd_screenWidth]/3, 17) offset:CGPointMake(0, 0)];
        [self.indicateView zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.statusView size:CGSizeMake([UIScreen wd_screenWidth]/3, 2) offset:CGPointMake(0, 0)];
    } else {
        [self.scButton zk_AlignInner:ZK_AlignTypeCenterLeft referView:self.statusView size:CGSizeMake([UIScreen wd_screenWidth]/2, 17) offset:CGPointMake(0, 0)];
        [self.nsButton zk_AlignInner:ZK_AlignTypeCenterRight referView:self.statusView size:CGSizeMake([UIScreen wd_screenWidth]/2, 17) offset:CGPointMake(0, 0)];
        [self.indicateView zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.statusView size:CGSizeMake([UIScreen wd_screenWidth]/2, 2) offset:CGPointMake(0, 0)];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ![self.taskModel.zylx isEqualToString:@""] ? 3 : 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor randomColor];
    UIViewController *v = ![self.taskModel.zylx isEqualToString:@""] ? (indexPath.row == 0 ? self.scvc : (indexPath.row == 1 ? self.slvc : self.nsvc)) : (indexPath.row == 0 ? self.scvc : self.nsvc);
    [cell.contentView addSubview:v.view];
    [v.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(cell.contentView);
    }];
    return cell;
}

- (void)loadData {
    NSInteger type = [self.taskModel.zylx isEqualToString:@""] ? 1 : 0;
    WEAKSELF(self);
    [HWTaskListRequest fetchPublicDataSourceWith:self.taskModel.zyID fbdxID:self.taskModel.fbdxID fbdxlx:self.taskModel.fbdxlx type:type handler:^(NSArray *data) {
        weakSelf.scvc.data = data[0];
        if (![self.taskModel.zylx isEqualToString:@""]) {
            weakSelf.slvc.data = data[1];
        }
        weakSelf.nsvc.data = data[2];
        [weakSelf resetSubmitStatusCount];
        self.studentData = data;
    }];
}

- (void)changeCurrentControllerWith:(UIButton *)btn {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:btn.tag inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetx = scrollView.contentOffset.x * (([UIScreen wd_screenWidth] / (![self.taskModel.zylx isEqualToString:@""] ? 3 : 2)) / [UIScreen wd_screenWidth]);
    self.indicateView.x = offsetx;
}

///  重置提交状态数量
- (void)resetSubmitStatusCount {
    BOOL isTest = ([self.taskModel.zylx isEqualToString:@""] || self.taskModel.zylx == nil) ? true : false;
    [self.scButton setTitle:[NSString stringWithFormat:@"%@(%tu)", isTest ? NSLocalizedString(@"已提交", nil) : NSLocalizedString(@"待批改", nil), [self.scvc.data count]] forState:UIControlStateNormal];
    if (![self.taskModel.zylx isEqualToString:@""]) {
        [self.slButton setTitle:[NSString stringWithFormat:@"%@(%tu)", NSLocalizedString(@"已批改", nil), [self.slvc.data count]] forState:UIControlStateNormal];
    }
    [self.nsButton setTitle:[NSString stringWithFormat:@"%@(%tu)", NSLocalizedString(@"未提交", nil), [self.nsvc.data count]] forState:UIControlStateNormal];
}

- (void)loadTaskData {
    WEAKSELF(self);
    if ([self.taskModel.zylx isEqualToString:@"1"]) { //非在线
        [HWNotOnlineRequest getNotOnlineFeedBackWith:self.taskModel.zyID fbdxlx:self.taskModel.fbdxlx fbdxId:self.taskModel.fbdxID handler:^(NSArray *data) {
            weakSelf.scvc.notOnlineData = data;
            if (![self.taskModel.zylx isEqualToString:@""]) {
                weakSelf.slvc.notOnlineData = data;
            }
            weakSelf.nsvc.notOnlineData = data;
        }];
    } else if ([self.taskModel.zylx isEqualToString:@"2"]) { //在线
//        [HWOnlineRequest fetchPublicOnlineTaskFeedbackDataWith:self.taskModel handler:^(NSArray *data) {
//            weakSelf.scvc.onlineData = data;
//            weakSelf.slvc.onlineData = data;
//            weakSelf.nsvc.onlineData = data;
//            weakSelf.studentAnswerData = data;
//        }];
    } else if ([self.taskModel.zylx isEqualToString:@""]) { //预习
    } else if ([self.taskModel.zylx isEqualToString:@"3"]) { // 拍照作业
        // 获取作业详情
        
        [HWPhotographModel getPhotoraphTaskDetailWithZYID:self.taskModel.zyID handler:^(NSArray *stData) {
            weakSelf.scvc.onlineData = stData;
            weakSelf.slvc.onlineData = stData;
            weakSelf.nsvc.onlineData = stData;
        }];
        [HWPhotographModel getPhotoraphTaskFeedbackWithFbdxId:self.taskModel.fbdxID fbdxlx:self.taskModel.fbdxlx zyId:self.taskModel.zyID handler:^(NSArray *xsData) {
            weakSelf.scvc.notOnlineData = xsData;
            weakSelf.slvc.notOnlineData = xsData;
            weakSelf.nsvc.notOnlineData = xsData;
        }];
        
    }
}

@end
