
//
//  HWReleaseTaskTypeView.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWReleaseTaskTypeView.h"
#import "CenterTitleCollectionViewCell.h"
#import "StudentIconCollectionViewCell.h"
#import <UIImageView+WebCache.h>

@interface HWReleaseTaskTypeView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UICollectionView *collectionView;
///  遮罩按钮
@property (nonatomic, strong) UIButton *shadeButton;

@property (nonatomic, copy) NSArray *dataSourceStr;

@property (nonatomic, copy) NSArray *dataSourceColor;

@end

@implementation HWReleaseTaskTypeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.shadeButton = [UIButton new];
    self.shadeButton.backgroundColor = [UIColor hex:0x00000 alpha:0.4];
    self.shadeButton.alpha = 0.0;
    [self addSubview:self.shadeButton];
    [self.shadeButton addTarget:self action:@selector(dismissCurrentView) forControlEvents:UIControlEventTouchUpInside];
    
    self.layout = [UICollectionViewFlowLayout new];
    self.layout.minimumLineSpacing = 0.5;
    self.layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = false;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    [self.collectionView registerClass:[StudentIconCollectionViewCell class] forCellWithReuseIdentifier:@"StudentIconCollectionViewCell"];
    [self addSubview:self.collectionView];
}

- (void)initAutoLayout {
    [self.shadeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.right.offset(-1);
        make.height.offset(410);
    }];
}

#pragma mark - collectionview delegate datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 4 || indexPath.row == 8) {
        CenterTitleCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
        cell.label.text = NSLocalizedString(self.dataSourceStr[indexPath.row], nil);
        cell.label.numberOfLines = 0;
        cell.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.rightView.backgroundColor = [UIColor grayColor];
        cell.contentView.backgroundColor = [UIColor hex:0xF2F2F2 alpha:1];
        return cell;
    } else {
        StudentIconCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"StudentIconCollectionViewCell" forIndexPath:indexPath];
        cell.imgView.backgroundColor = [UIColor hex:(uint)[self.dataSourceColor[indexPath.row] integerValue] alpha:1.0];
        if (indexPath.row == 1 || indexPath.row == 5) {
            cell.imgView.image = [UIImage imageNamed:@"hw_release_class_1"];
        } else if (indexPath.row == 2 || indexPath.row == 6 || indexPath.row == 10) {
            cell.imgView.image = [UIImage imageNamed:@"hw_release_class_2"];
        } else if (indexPath.row == 3 || indexPath.row == 7 || indexPath.row == 11) {
            cell.imgView.image = [UIImage imageNamed:@"hw_release_class_3"];
        }
        cell.imgView.contentMode = UIViewContentModeCenter;
        cell.nameLabel.text = NSLocalizedString(self.dataSourceStr[indexPath.row], nil);
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataSourceStr.count - 1) {
        self.collectionView.y = -410;
    }
    if (indexPath.row == 0 || indexPath.row == 4 || indexPath.row == 8) {
        return CGSizeMake(self.collectionView.w, 36);
    } else {
        CGFloat w = (self.collectionView.w-1) / 3.0;
        return CGSizeMake(w, 100);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = @[@1, @2, @3, @5, @6, @7, @10, @11];
    if ([array containsObject:@(indexPath.row)]) {
        if (self.didSel) {
            self.didSel(indexPath.row);
        }
    }
}

///  消失当前view
- (void)dismissCurrentView {
    if (self.selAndCancel) {
        self.selAndCancel();
    }
}

- (void)showChangeReleaseTypeWith:(BOOL)type {
    [UIView animateWithDuration:0.5 animations:^{
        self.shadeButton.alpha = type ? 1.0 : 0.0;
        self.collectionView.y = !type ? -410 : 0;
    }];
}

- (NSArray *)dataSourceStr {
    return @[@"按班级", @"分别", @"定时", @"立即", @"按小组", @"分别", @"定时", @"立即", @"按个人", @"", @"定时", @"立即"];
}

- (NSArray *)dataSourceColor {
    return @[@"", @0x55B167, @0xDD445B, @0x903DC0, @"", @0x4079D4, @0xEE9F46, @0x9A573D, @"", @0xFFFFFF, @0x56B365, @0x41A2DC];
}

@end
