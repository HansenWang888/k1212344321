//
//  WDChooseCourseView.h
//  wdk12IPhone
//
//  Created by 官强 on 16/12/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  选择课程view
 */
@class WDCourseDetailModel;
@interface WDChooseCourseView : UIView//306

@property (nonatomic, strong) NSArray *courses;

@property (nonatomic, copy) void (^cancleBlock)();
@property (nonatomic, copy) void (^confirmBlock)(WDCourseDetailModel *courseModel);

@end
