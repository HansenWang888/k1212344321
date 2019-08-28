//
//  HWOnlineNavView.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

///  题目导航view
@interface HWOnlineNavView : UIView

///

///  显示导航控制器
///
///  @param count 总数
///  @param index 当前选中的
///  @param array 主观题数组
///
///  @return 自己
+ (HWOnlineNavView *)showNavViewActionWithCount:(NSInteger)count index:(NSInteger)index count:(NSArray *)array;

//多加一个显示标题数组
+ (HWOnlineNavView *)showNavViewActionWithCount:(NSInteger)count index:(NSInteger)index count:(NSArray *)array titleArray:(NSArray *)titleArray;

@property (nonatomic, copy) void(^didSelect)(NSInteger index);

@end
