//
//  ScheduleTableViewCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/21.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDCourseList;

///  课程详细计划表
@interface ScheduleTableViewCell : UITableViewCell

- (void)setValueForDataSource:(WDCourseList *)data isMySchedule:(BOOL)isMySchedule;

@end
