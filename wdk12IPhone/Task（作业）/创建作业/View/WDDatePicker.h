//
//  WDDatePicker.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/10/19.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDDatePicker : UIView

///  显示时间选择
///
///  @param v 需要添加的view
+ (WDDatePicker *)showTimeSelectWith:(UIView *)v date:(NSDate *)date;

@property (nonatomic, copy) void(^didTime)(NSDate *date);

@end
