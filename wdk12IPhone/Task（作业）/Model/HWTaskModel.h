//
//  HWTaskModel.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

///  作业模型
@interface HWTaskModel : NSObject

///  作业类型 1 非在线 2 在线  空预习
@property (nonatomic, copy) NSString *zylx;
/// 年级名称
@property (nonatomic, copy) NSString *njmc;
///  发布对象id
@property (nonatomic, copy) NSString *fbdxID;
///  发布日期
@property (nonatomic, copy) NSString *fbrq;
///  发布对象类型
@property (nonatomic, copy) NSString *fbdxlx;
/// 已反馈数
@property (nonatomic, copy) NSString *yfks;
/// 课程名称
@property (nonatomic, copy) NSString *ksms;
///  已提交数
@property (nonatomic, copy) NSString *ytjs;
///  截止日期
@property (nonatomic, copy) NSString *jzrq;
///  作业id
@property (nonatomic, copy) NSString *zyID;
///  总人数
@property (nonatomic, copy) NSString *zrs;
///  作业性质 1 2
@property (nonatomic, copy) NSString *zyxz;
///  作业分类
@property (nonatomic, copy) NSString *zyfl;
///  作业代码
@property (nonatomic, copy) NSString *kmdm;
///  作业名称
@property (nonatomic, copy) NSString *zymc;
///  发布对象名称
@property (nonatomic, copy) NSString *fbdxmc;

+ (HWTaskModel *)objectWithDict:(NSDictionary *)dict;

@end
