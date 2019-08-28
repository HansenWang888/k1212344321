//
//  HWTaskListPreviewCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/10/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTaskModel;

@interface HWTaskListPreviewCell : UITableViewCell

///  底部view
@property (nonatomic, strong) UIView *bottomView;

- (void)setValueForDataSource:(HWTaskModel *)data;

@end
