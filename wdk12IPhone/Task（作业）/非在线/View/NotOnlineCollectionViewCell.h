//
//  NotOnlineCollectionViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/11.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWAccessoryModel;

@interface NotOnlineCollectionViewCell : UICollectionViewCell

///  删除按钮在右上角
@property (nonatomic, strong) UIButton *delButton;

@property (nonatomic, strong) HWAccessoryModel *data;

@end
