//
//  HWPhotoViewController.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPhotoViewController.h"
#import "HWPhotoCheckImageViewCell.h"
#import <UIImageView+WebCache.h>
#import "HWPhotographModel.h"

@interface HWPhotoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UIPageControl *pageControl;
///  是否滚动过
@property (nonatomic, assign) BOOL isScroll;

@end

@implementation HWPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initAutoLayout];
    [self.collectionView setContentOffset:CGPointMake(([UIScreen wd_screenWidth]+20)*self.index, 64)];
}

- (void)initView {
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    [self.collectionView registerClass:[HWPhotoCheckImageViewCell class] forCellWithReuseIdentifier:@"HWPhotoCheckImageViewCell"];
    self.collectionView.pagingEnabled = true;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = false;
    self.pageControl.pageIndicatorTintColor = [UIColor hex:0xCCCCCC alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor hex:0x229BFC alpha:1.0];
    [self.view addSubview:self.pageControl];
}

- (void)initAutoLayout {
    CGFloat h = [UIScreen wd_screenHeight];
    self.collectionView.frame = CGRectMake(-20, 0, [UIScreen wd_screenWidth]+20, h);
    [self.pageControl zk_AlignInner:ZK_AlignTypeBottomCenter referView:self.view size:CGSizeZero offset:CGPointZero];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.fkList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWPhotoCheckImageViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"HWPhotoCheckImageViewCell" forIndexPath:indexPath];
    cell.superViewController = self;
    NSString *str = [self.dataSource.fkList[indexPath.row] xsfjdz];
    [cell setImageViewWithData:str];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
