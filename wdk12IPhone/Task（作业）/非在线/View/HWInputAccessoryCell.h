//
//  HWInputAccessoryCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWAccessoryModel;

///  添加附件数据源cell
@interface HWInputAccessoryCell : UITableViewCell

///  附件数据源
@property (nonatomic, strong) NSMutableArray<HWAccessoryModel *> *data;

@property (nonatomic, weak) UIViewController *superViewController;


- (void)addImage:(UIImage *)image;

@end
