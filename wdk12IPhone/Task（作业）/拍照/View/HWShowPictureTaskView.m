//
//  HWShowPictureTaskView.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/10.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWShowPictureTaskView.h"
#import "HWShowPictureTaskCell.h"
#import "HWPhotographModel.h"
#import <UIImageView+WebCache.h>
#import "HWPhotoViewController.h"
#import "HWPhotoDetailViewController.h"

@interface HWShowPictureTaskView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) HWPhotographModel *dataSource;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation HWShowPictureTaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 0;
    [self.collectionView registerClass:[HWShowPictureTaskCell class] forCellWithReuseIdentifier:@"HWShowPictureTaskCell"];
    self.collectionView.pagingEnabled = true;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = false;
    self.pageControl.pageIndicatorTintColor = [UIColor hex:0xCCCCCC alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor hex:0x229BFC alpha:1.0];
    [self addSubview:self.pageControl];
    self.clipsToBounds = true;
}

- (void)initAutoLayout {
    CGFloat h = [UIScreen wd_screenHeight];
    self.collectionView.frame = CGRectMake(-20, 0, [UIScreen wd_screenWidth]+20, (h - 64) * 0.5 - 50);
    [self.pageControl zk_AlignInner:ZK_AlignTypeBottomCenter referView:self size:CGSizeZero offset:CGPointZero];
}

- (void)setValueForDataSource:(HWPhotographModel *)data {
    self.dataSource = data;
    self.pageControl.numberOfPages = data.fkList.count;
    [self.collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.fkList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWShowPictureTaskCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"HWShowPictureTaskCell" forIndexPath:indexPath];
    NSString *str = [self.dataSource.fkList[indexPath.row] xsfjdz];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:str]];
    cell.stateLabel.text = [[self.dataSource.fkList[indexPath.row] pgfjList] count] ? NSLocalizedString(@"已反馈", nil) : NSLocalizedString(@"未反馈", nil);
    cell.clipsToBounds = true;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HWPhotoDetailViewController *vc = [HWPhotoDetailViewController new];
    vc.model = self.dataSource.fkList[indexPath.row];
    
    WEAKSELF(self);
    vc.saveBack = ^(HWPhotographModel *model) {
        [weakSelf.dataSource.fkList replaceObjectAtIndex:indexPath.row withObject:model];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    };
    [self.superViewController presentViewController:vc animated:true completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int current = (int)(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
    self.pageControl.currentPage = current;
    if (self.currentPage) {
        self.currentPage(current);
    }
}

@end
