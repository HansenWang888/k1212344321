//
//  HWPreviewViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPreviewViewController.h"
#import "HWPracticeViewController.h"
#import "HWPractiveBaseViewController.h"
#import "HWPreviewDataController.h"
#import "HWTaskPreviewPractice.h"
#import "HWTaskPreviewModel.h"
#import "HWPreviewRequest.h"

@interface HWPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  资料控制器
@property (nonatomic, strong) HWPreviewDataController *dataVC;
///  基础练习控制器 // HWPracticeViewController
@property (nonatomic, strong) HWPracticeViewController *baseTestVC;
///  扩展练习控制器
@property (nonatomic, strong) HWPracticeViewController *extensionVC;

@property (nonatomic, strong) HWTaskPreviewModel*data;

@end

@implementation HWPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self loadData];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"预习资料", nil),
                                                                        NSLocalizedString(@"基础练习", nil),
                                                                        NSLocalizedString(@"拓展练习", nil)]];
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} forState:UIControlStateNormal];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
    
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.itemSize = CGSizeMake([UIScreen wd_screenWidth], [UIScreen wd_screenHeight] - 64);
    self.collectionView.pagingEnabled = true;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView zk_Fill:self.view insets:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    self.dataVC = [HWPreviewDataController new];
    self.baseTestVC = [HWPracticeViewController new];
    self.extensionVC = [HWPracticeViewController new];
    self.baseTestVC.isSubmit = self.isSubmit;
    self.extensionVC.isSubmit = self.isSubmit;
    
    [self addChildViewController:self.dataVC];
    [self addChildViewController:self.baseTestVC];
    [self addChildViewController:self.extensionVC];
}

- (void)segmentedControlAction:(UISegmentedControl *)segmentedControl {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:segmentedControl.selectedSegmentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:false];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UIView *v;
    if (indexPath.row == 0) {
        v = self.dataVC.view;
    } else if (indexPath.row == 1) {
        v = self.baseTestVC.view;
    } else if (indexPath.row == 2) {
        v = self.extensionVC.view;
    }
    v.alpha = 1;
    [cell.contentView addSubview:v];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(cell.contentView);
    }];
    return cell;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int currentIndex = (self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
    self.segmentedControl.selectedSegmentIndex = currentIndex;
}

- (void)loadData {
    WEAKSELF(self);
    [HWPreviewRequest fetchPublicPreviewTaskDataWith:self.taskId handler:^(HWTaskPreviewModel *data) {
        weakSelf.data = data;
        for (HWTaskPreviewPractice *item in data.lxList) {
            if ([item.lxbm isEqualToString:@"2"]) {
                self.baseTestVC.testId = item.xqID;
                self.baseTestVC.studentId = weakSelf.studentId;
            } else {
                self.extensionVC.testId = item.xqID;
                self.extensionVC.studentId = weakSelf.studentId;
            }
        }
    }];
}

- (void)setData:(HWTaskPreviewModel *)data {
    _data = data;
    self.dataVC.data = self.data.zlList;
}

@end
