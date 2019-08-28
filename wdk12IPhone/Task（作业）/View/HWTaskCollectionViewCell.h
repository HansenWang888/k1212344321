//
//  HWTaskCollectionViewCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StudentModel;

@interface HWTaskCollectionViewCell : UICollectionViewCell

///  小组
@property (nonatomic, strong) UILabel *smallLabel;

- (void)setValueForDataSource:(StudentModel *)data;

@end
