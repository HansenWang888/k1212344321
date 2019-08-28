//
//  WDHTTPManager.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/18.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <AFNetworking.h>

@class MediaOBJ;

@interface WDHTTPManager : NSObject

+ (instancetype)sharedHTTPManeger;

/**
 *  登录验证
 *
 *  @param account  帐号
 *  @param password 密码
 *  @param finished 回调
 */
- (void)verifyLoginWithAccount:(NSString *)account password:(NSString *)password finished: (void(^)(NSDictionary *dict))finished;

/**
 *  获取登录角色信息
 *
 *  @param loginID 登录ID
 *  @param finish  回调
 */
- (void)loginIDWithUserInfo:(NSString *)loginID userType:(NSString *)userType finished:(void (^)(NSDictionary *))finish;
/**
 *  加载我的课表
 *  @param userID   教师ID
 *  @param date     日期
 *  @param finished 回调
 */
- (void)loadMyCourseListWithID:(NSString *)ID date:(NSString *)date paramKey:(NSString *)key method:(NSString *)method finished:(void (^)(NSDictionary *))finished;
/**
 *  上传图片
 *
 *  @param pictures 图片数组
 */
- (void)uploadWithPicture:(NSArray *)pictures finished:(void(^)(NSDictionary *))finished;
/**
 *  get方式获取数据
 *
 *  @param prameter 参数
 *  @param finished 回调
 */
- (void)getMethodDataWithParameter:(NSDictionary *)prameter urlString:(NSString *)urlString finished:(void(^)(NSDictionary *))finished;
/**
 *  post方式提交数据
 *
 *  @param prameter 参数
 *  @param finished 回调
 */
- (void)postMethodDataWithParameter:(NSDictionary *)prameter urlString:(NSString *)urlString finished:(void(^)(NSDictionary *))finished;
/**
 *  post方式访问HTTPS
 *  @param urlString 地址
 *  @param dict 参数
 *  @param finished 回调
 */
- (void)postHTTPSWithParameterDict:(NSDictionary *)dict urlString:(NSString *)urlString contentType:(NSString *)contentType finished:(void(^)(NSDictionary *dict))finished;

- (void)uploadWithAdjunctFileWithData:(NSArray<MediaOBJ *> *)array progressBlock:(void (^)(double))progressBlock finished:(void(^)(NSDictionary *))finished;
@end
