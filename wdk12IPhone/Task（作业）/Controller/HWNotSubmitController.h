//
//  HWNotSubmitController.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTaskModel;
@class HWStudentTask;

@interface HWNotSubmitController : UIViewController

///  数据源
@property (nonatomic, copy) NSArray *data;

///  作业模型
@property (nonatomic, strong) HWTaskModel *taskModel;
///  非在线数据
@property (nonatomic, strong) NSArray *notOnlineData;
///  在线数据
@property (nonatomic, strong) NSArray *onlineData;

@end
