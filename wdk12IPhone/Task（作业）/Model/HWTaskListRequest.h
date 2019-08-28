//
//  HWTaskListRequest.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

///  作业列表请求
@interface HWTaskListRequest : NSObject

///  获取教师所有科目
///
///  @param handler 回调
+ (void)fetchPublicTeacherSubject:(void(^)(NSArray *data))handler;
///  获取作业提交状态
///
///  @param zyID    作业id
///  @param fbdxID  发布对象id
///  @param fbdxlx  发布对象类型
///  @param type    类型 作业 or 课程
///  @param handler 回调
+ (void)fetchPublicDataSourceWith:(NSString *)zyID fbdxID:(NSString *)fbdxID fbdxlx:(NSString *)fbdxlx type:(NSInteger)type handler:(void(^)(NSArray *data))handler;

@end
