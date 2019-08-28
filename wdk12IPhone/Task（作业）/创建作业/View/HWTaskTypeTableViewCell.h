//
//  HWTaskTypeTableViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/6.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

///  作业类型cell
@interface HWTaskTypeTableViewCell : UITableViewCell

///  选择的类型 1作业 2预习 3复习
@property (nonatomic, copy) void(^didSelType)(NSInteger type);

@end
