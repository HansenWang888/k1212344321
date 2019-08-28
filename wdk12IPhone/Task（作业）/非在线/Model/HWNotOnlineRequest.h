//
//  HWNotOnlineRequest.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWStudentTask;
@class HWNotOnlineModel;

@interface HWNotOnlineRequest : NSObject

///  获取非在线作业数据
///
///  @param taskId  作业id
///  @param handler 回调
+ (void)getNotOnlineTaskDetailWith:(NSString *)taskId handler:(void(^)(HWNotOnlineModel *data))handler;

///  提交非在线作业反馈
///
///  @param xsId    学生id
///  @param taskId  作业id
///  @param zypf    作业评分
///  @param zypy    作业评语
///  @param fjList  附件列表
///  @param handler 回调
+ (void)submitTaskWith:(NSString *)xsId taskId:(NSString *)taskId zypf:(NSString *)zypf zypy:(NSString *)zypy fjList:(NSArray *)fjList handler:(void(^)(BOOL isSucceess))handler;

///  获取非在线作业反馈
///
///  @param zyId    作业id
///  @param fbdxlx  发布对象类型
///  @param fbdxId  发布对象id
///  @param handler 回调
+ (void)getNotOnlineFeedBackWith:(NSString *)zyId fbdxlx:(NSString *)fbdxlx fbdxId:(NSString *)fbdxId handler:(void(^)(NSArray *data))handler;

@end
