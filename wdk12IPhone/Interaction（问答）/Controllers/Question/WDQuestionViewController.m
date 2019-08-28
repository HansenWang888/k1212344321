//
//  WDQuestionViewController.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDQuestionViewController.h"
#import "WDAllQuestionViewController.h"
#import "WDMyQuestionViewController.h"
#import "WDAskByMeViewController.h"

@interface WDQuestionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segementCtrl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray  *subCells;

@property (nonatomic, strong) WDAllQuestionViewController *allQuestionVC;
@property (nonatomic, strong) WDMyQuestionViewController  *myQuestionVC;

@end

@implementation WDQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _subCells = @[].mutableCopy;
    [self.subCells addObjectsFromArray:@[self.allQuestionVC.view,self.myQuestionVC.view]];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    //添加nav右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(clickNavRightBtn)];
}

- (void)clickNavRightBtn {
    //点击nav右边按钮
    WDAskByMeViewController *questionVC = [[WDAskByMeViewController alloc] init];
    WEAKSELF(self);
    questionVC.confirmSuccess = ^{
//        [weakSelf.myQuestionVC updateData];
//        [weakSelf.allQuestionVC updateData];
    };
    [questionVC setHidesBottomBarWhenPushed:true];
    [self.navigationController pushViewController:questionVC animated:YES];
}

- (IBAction)segeCtrlClicked:(UISegmentedControl *)sender {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:sender.selectedSegmentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UIView *view = self.subCells[indexPath.row];
    [cell.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat index = self.collectionView.contentOffset.x;
    if (index > self.collectionView.w/2.0) {
        self.segementCtrl.selectedSegmentIndex = 1;
    }else {
        self.segementCtrl.selectedSegmentIndex = 0;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.segementCtrl.selectedSegmentIndex == 0) {
        [self.allQuestionVC updateData];
    }else {
        [self.myQuestionVC updateData];
    }
}

- (WDAllQuestionViewController *)allQuestionVC {
    if (!_allQuestionVC) {
        _allQuestionVC = [WDAllQuestionViewController new];
        [self addChildViewController:_allQuestionVC];
    }
    return _allQuestionVC;
}

- (WDMyQuestionViewController *)myQuestionVC {
    if (!_myQuestionVC) {
        _myQuestionVC = [WDMyQuestionViewController new];
        [self addChildViewController:_myQuestionVC];
    }
    return _myQuestionVC;
}

@end
