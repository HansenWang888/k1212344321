//
//  HWSelectTestView.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/15.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWSelectTestView.h"
#import "CenterTitleCollectionViewCell.h"

@interface HWSelectTestView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  最后一次选中的cell
@property (nonatomic, assign) NSInteger lastSel;
///  当前标题
@property (nonatomic, strong) UILabel *currentTitleLabel;
///  总数标题
@property (nonatomic, strong) UILabel *countTitleLabel;
///  遮罩按钮
@property (nonatomic, strong) UIButton *shadeButotn;
///  背景view
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, copy) void(^didSel)(NSInteger index);

@end

@implementation HWSelectTestView

+ (HWSelectTestView *)showSelectTestViewWith:(UIView *)view count:(NSInteger)count currentIndex:(NSInteger)index didSel:(void(^)(NSInteger row))didSel {
    HWSelectTestView *v = [HWSelectTestView new];
    [view addSubview:v];
    [v zk_Fill:view insets:UIEdgeInsetsZero];
    v.count = count;
    v.lastSel = index;
    v.currentSel = index;
    v.didSel = didSel;
    v.shadeButotn.alpha = 0;
    v.backgroundView.x = [UIScreen wd_screenWidth];
    [UIView animateWithDuration:0.3 animations:^{
        v.shadeButotn.alpha = 1;
        v.backgroundView.x = 80;
    }];
    return v;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.shadeButotn = [UIButton new];
    self.shadeButotn.backgroundColor = [UIColor hex:0x000000 alpha:0.4];
    [self.shadeButotn addTarget:self action:@selector(dismissSelectTestViewAction) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundView = [UIView viewWithBackground:[UIColor hex:0xF6F6F6 alpha:1.0] alpha:1.0];
    
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.layout.minimumLineSpacing = 20;
    self.layout.minimumInteritemSpacing = 15;
    self.layout.itemSize = CGSizeMake(30, 30);
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    self.topicNavButton = [UIButton new];
    [self.topicNavButton setImage:[UIImage imageNamed:@"hw_title_nav"] forState:UIControlStateNormal];
    [self.topicNavButton addTarget:self action:@selector(dismissSelectTestViewAction) forControlEvents:UIControlEventTouchUpInside];
    self.collectionView.backgroundColor = [UIColor hex:0x535353 alpha:1.0];
    self.lastSel = 0;
    
    self.currentTitleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0xFF4E00 alpha:1.0] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.countTitleLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:17] alpha:1.0];
    
    [self addSubview:self.shadeButotn];
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.countTitleLabel];
    [self.backgroundView addSubview:self.currentTitleLabel];
    [self.backgroundView addSubview:self.topicNavButton];
    [self.backgroundView addSubview:self.collectionView];
}

- (void)initAutoLayout {
    [self.shadeButotn zk_Fill:self insets:UIEdgeInsetsZero];
    [self.backgroundView zk_Fill:self insets:UIEdgeInsetsMake(0, 80, 0, 0)];
    [self.countTitleLabel zk_AlignInner:ZK_AlignTypeTopCenter referView:self.backgroundView size:CGSizeZero offset:CGPointMake(0, 10)];
    [self.currentTitleLabel zk_AlignHorizontal:ZK_AlignTypeCenterLeft referView:self.countTitleLabel size:CGSizeZero offset:CGPointZero];
    [self.topicNavButton zk_AlignInner:ZK_AlignTypeTopRight referView:self.backgroundView size:CGSizeMake(20, 20) offset:CGPointMake(-10, 10)];
    [self.collectionView zk_Fill:self.backgroundView insets:UIEdgeInsetsMake(40, 0, 0, 0)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CenterTitleCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
    [cell.rightView removeFromSuperview];
    cell.contentView.layer.cornerRadius = 15;
    cell.contentView.layer.masksToBounds = true;
    cell.contentView.backgroundColor = self.currentSel == indexPath.row ? [UIColor hex:0x4CB757 alpha:1.0] : [UIColor whiteColor];
    cell.label.text = [NSString stringWithFormat:@"%tu", indexPath.row + 1];
    cell.label.textColor = self.currentSel == indexPath.row ? [UIColor whiteColor] : [UIColor grayColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastSel == indexPath.row) {
        return ;
    }
    self.currentSel = indexPath.row;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.lastSel inSection:0], indexPath]];
    self.lastSel = indexPath.row;
    self.currentTitleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    if (self.didSel) {
        self.didSel(indexPath.row);
    }
    [self dismissSelectTestViewAction];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    [self.collectionView reloadData];
    self.currentTitleLabel.text = @"1";
    self.countTitleLabel.text = [NSString stringWithFormat:@"/%tu", self.count];
}

- (void)dismissSelectTestViewAction {
    WEAKSELF(self);
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.shadeButotn.alpha = 0;
        weakSelf.backgroundView.x = [UIScreen wd_screenWidth];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
