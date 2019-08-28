//
//  MOSelectSubjectCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/30.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "MOSelectSubjectCell.h"
#import "CenterTitleCollectionViewCell.h"
#import "HWSubject.h"

@interface MOSelectSubjectCollectionViewFlowLayout : UICollectionViewFlowLayout
@end

@interface MOSelectSubjectCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) MOSelectSubjectCollectionViewFlowLayout *layout;

@end

@implementation MOSelectSubjectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.layout = [MOSelectSubjectCollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self.contentView addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.layout.minimumLineSpacing = 5;
    self.layout.minimumInteritemSpacing = 5;
    self.collectionView.scrollEnabled = false;
    [self.collectionView registerClass:[CenterTitleCollectionViewCell class] forCellWithReuseIdentifier:@"CenterTitleCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)initAutoLayout {
    [self.collectionView zk_Fill:self.contentView insets:UIEdgeInsetsZero];
}

- (void)setData:(NSArray<HWSubject *> *)data {
    _data = data;
    [self.collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

#pragma mark collectionview delegate datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CenterTitleCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CenterTitleCollectionViewCell" forIndexPath:indexPath];
    HWSubject *sub = self.data[indexPath.row];
    cell.label.font = [UIFont systemFontOfSize:14];
    cell.label.text = sub.subjectCH;
    cell.contentView.layer.cornerRadius = 10;
    cell.contentView.backgroundColor = sub.isSel ? [UIColor grayColor] : (sub.on ? [UIColor hex:0x157EFB alpha:1.0] : [UIColor clearColor]);
    cell.label.textColor = (sub.isSel || sub.on) ? [UIColor whiteColor] : [UIColor grayColor];
    cell.userInteractionEnabled = sub.isSel ? false : true;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w =  [self.data[indexPath.row].subjectCH sizeOfStringWithFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
    return CGSizeMake(w + 30, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HWSubject *sub = self.data[indexPath.row];
    sub.on = !sub.isOn;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

///  获取需要添加的科目id数据
- (NSMutableString *)getNeedAddSubjectIdData {
    NSMutableString *strM = [NSMutableString string];
    for (HWSubject *item in self.data) {
        if (item.isOn) {
            [strM appendString:[NSString stringWithFormat:@"%@,", item.subjectID]];
        }
    }
    return strM;
}

@end

@implementation MOSelectSubjectCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
        if (nil == attributes.representedElementKind) {
            NSIndexPath* indexPath = attributes.indexPath;
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return attributesToReturn;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* currentItemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout sectionInset];
    
    if (indexPath.item == 0) {
        CGRect frame = currentItemAttributes.frame;
        frame.origin.x = sectionInset.left;
        currentItemAttributes.frame = frame;
        return currentItemAttributes;
    }
    
    NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + 5;
    
    CGRect currentFrame = currentItemAttributes.frame;
    CGRect strecthedCurrentFrame = CGRectMake(0, currentFrame.origin.y, self.collectionView.frame.size.width, currentFrame.size.height);
    
    if (!CGRectIntersectsRect(previousFrame, strecthedCurrentFrame)) {
        CGRect frame = currentItemAttributes.frame;
        frame.origin.x = sectionInset.left;
        currentItemAttributes.frame = frame;
        return currentItemAttributes;
    }
    
    CGRect frame = currentItemAttributes.frame;
    frame.origin.x = previousFrameRightPoint;
    currentItemAttributes.frame = frame;
    return currentItemAttributes;
}

@end
