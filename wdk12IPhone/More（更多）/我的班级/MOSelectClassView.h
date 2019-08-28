//
//  MOSelectClassView.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

///  更多模块选择班级view
@interface MOSelectClassView : UIView

///  显示班级选择
///
///  @param v     需要添加到的控制器
///  @param title 标题
///  @param data  数据源
///
///  @return 本身
+ (MOSelectClassView *)showClassSelectWith:(UIView *)v title:(NSString *)title data:(NSArray *)data;

@property (nonatomic, copy) void(^didSel)(NSIndexPath *index);

@end
