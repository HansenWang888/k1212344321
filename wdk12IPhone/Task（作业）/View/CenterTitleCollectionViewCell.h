//
//  CenterTitleCollectionViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/2.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWSubject;

///  中间是个title的collectionViewCell
@interface CenterTitleCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

///  右边阴影view
@property (nonatomic, strong) UIView *rightView;

- (void)setValueForDataSource:(HWSubject *)data;

@end
