//
//  HWSubjectTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/6.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWSubjectTableViewCell.h"
#import "CenterTitleCollectionViewCell.h"
#import "HWSubject.h"

@interface HWSubjectTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource>

///  layout
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

///  数据源
@property (nonatomic, strong) NSArray *dataSource;
///  临时数据
@property (nonatomic, strong) HWSubject *tempData;
///  后一个选中的索引
@property (nonatomic, strong) NSIndexPath *lastIndex;

@end

@implementation HWSubjectTableViewCell

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
    self.collectionView.backgroundColor = [UIColor whiteColor];
    CGFloat w = ([UIScreen wd_screenWidth] - 41) / 3;
    self.layout.itemSize = CGSizeMake(w, 30);
    self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    [self.contentView addSubview:self.collectionView];
}

- (void)initAutoLayout {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.contentView);
    }];
}

- (void)setValueForDataSource:(NSArray *)data {
    self.dataSource = data;
    [self.collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

#pragma mark - collectionView delegate and dataSouce
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CenterTitleCollectionViewCell *cell = (CenterTitleCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
    cell.label.font = [UIFont systemFontOfSize:14];
    cell.label.numberOfLines = 2;
    cell.label.adjustsFontSizeToFitWidth = YES;
    [cell setValueForDataSource:self.dataSource[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath) { return ; }
    HWSubject *item = self.dataSource[indexPath.row];
    item.isSel = !item.isSel;
    self.tempData.isSel = !self.tempData.isSel;
    if (self.lastIndex) {
        [self.collectionView reloadItemsAtIndexPaths:@[self.lastIndex, indexPath]];
    } else {
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    self.tempData = item;
    self.lastIndex = indexPath;
    if (self.didSelectSubject) {
        self.didSelectSubject(item);
    }
}


@end
