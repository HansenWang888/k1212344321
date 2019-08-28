//
//  StudentIconCollectionViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/20.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StudentModel;

@interface StudentIconCollectionViewCell : UICollectionViewCell

///  头像label
@property (nonatomic, strong) UIImageView *imgView;
///  姓名label
@property (nonatomic, strong) UILabel *nameLabel;

- (void)setValueForDataSource:(StudentModel *)data;

@end
