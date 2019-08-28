//
//  HWAnnesTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/10.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWAnnesTableViewCell.h"
#import "NotOnlineCollectionViewCell.h"

@interface HWAnnesTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource>

///  布局类
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
///  附件
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HWAnnesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.layout = [UICollectionViewFlowLayout new];
    self.layout.minimumLineSpacing = 10;
    self.layout.minimumInteritemSpacing = 10;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[NotOnlineCollectionViewCell class] forCellWithReuseIdentifier:@"NotOnlineCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    CGFloat w = ([UIScreen wd_screenWidth] - 40) / 3;
    self.layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0);
    self.layout.itemSize = CGSizeMake(w, 100);
    self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.contentView addSubview:self.collectionView];
}

- (void)initAutoLayout {
    [self.collectionView zk_Fill:self.contentView insets:UIEdgeInsetsZero];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NotOnlineCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"NotOnlineCollectionViewCell" forIndexPath:indexPath];
    cell.data = self.dataSource[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSel) {
        self.didSel(indexPath);
    }
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

@end
