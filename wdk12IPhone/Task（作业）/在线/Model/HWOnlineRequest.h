//
//  HWOnlineRequest.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/15.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWTaskModel;
@class HWOnlineTaskModel;

@interface HWOnlineRequest : NSObject

///  获取在线作业试题题型详情
///
///  @param taskId  作业id
///  @param handler 回调
+ (void)fetchOnlineTaskPatternContent:(NSString *)taskId handler:(void(^)(HWOnlineTaskModel *model))handler;

///  获取在线作业试卷详情
///
///  @param sjID    试卷id
///  @param handler 回调试题列表
+ (void)fetchPublicOnlineTaskQuestionPaperDataWith:(NSString *)sjID handler:(void(^)(NSArray *data))handler;
///  获取学生答案内容
///
///  @param zyId    作业id
///  @param xsId    学生id
///  @param fbdxId  发布对象id
///  @param sjId    试卷id
///  @param handler 回调作业内容
+ (void)fetchStudentAnswerContentWith:(NSString *)zyId xsId:(NSString *)xsId fbdxId:(NSString *)fbdxId sjId:(NSString *)sjId handler:(void(^)(NSDictionary *dict))handler;
///  在线作业反馈
///
///  @param zyId    作业id
///  @param sjId    试卷id
///  @param fbdxlx  发布对象类型
///  @param fbdxId  发布对象id
///  @param handler 回调
+ (void)fetchOnlineTaskFeedbackWith:(NSString *)zyId sjId:(NSString *)sjId fbdxlx:(NSString *)fbdxlx fbdxId:(NSString *)fbdxId handler:(void(^)(NSArray *da))handler;

///  在作作业客观题批改
///
///  @param zyId    作业id
///  @param fbdxId  发布对象id
///  @param jsId    教师id
///  @param xsId    学生id
///  @param handler 回调,是否成功
+ (void)onlineTaskObjectiveScoreWith:(NSString *)zyId fbdxId:(NSString *)fbdxId xsId:(NSString *)xsId handler:(void(^)(BOOL isSuccess))handler;


///  获取在线作业数据
///
///  @param taskID  作业id
///  @param handler 回调
+ (void)getOnlineTaskDataWith:(NSString *)taskID handler:(void(^)(NSArray *data))handler;

///  在线作业单题评分
///
///  @param xsId   学生id
///  @param fbdxId 发布对象id
///  @param zyId   作业id
///  @param sjId   试卷id
///  @param stId   试题id
///  @param xtId   小题id
///  @param stpf   评分
+ (void)onlineTaskScoreWith:(NSString *)xsId fbdxId:(NSString *)fbdxId zyId:(NSString *)zyId sjId:(NSString *)sjId stId:(NSString *)stId xtId:(NSString *)xtId stpf:(NSString *)stpf handler:(void(^)(BOOL isSuccess))handler;

@end
