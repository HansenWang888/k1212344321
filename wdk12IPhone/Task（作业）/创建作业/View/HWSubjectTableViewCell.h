//
//  HWSubjectTableViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/6.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWSubject;

///  科目cell
@interface HWSubjectTableViewCell : UITableViewCell
///  collectionView
@property (nonatomic, strong) UICollectionView *collectionView;
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, copy) void(^didSelectSubject)(HWSubject *sub);

- (void)setValueForDataSource:(NSArray *)data;

@end
