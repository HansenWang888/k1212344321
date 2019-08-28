//
//  HWTaskTimerModel.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

///  定时发布作业模型
@interface HWTaskTimerModel : NSObject

///  发布对象名称
@property (nonatomic, copy) NSString *name;
///  发布对象id
@property (nonatomic, copy) NSString *id;
///  所属班级id
@property (nonatomic, copy) NSString *classId;
///  发布时间
@property (nonatomic, strong) NSString *time;

@property (nonatomic, strong) NSDate *date;

@end
