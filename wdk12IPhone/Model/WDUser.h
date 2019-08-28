//
//  WDUser.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/25.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDUser : NSObject

@property (nonatomic, copy) NSString *userType;//用户类型
@property (nonatomic, copy) NSString *userID;//用户ID
@property (nonatomic, copy) NSString *email;//邮箱
@property (nonatomic, copy) NSString *PS;//个性签名personalized signature
@property (nonatomic, copy) NSString *nickName;//用户昵称
@property (nonatomic, copy) NSString *avatar;//用户头像
@property (nonatomic, copy) NSString *avatarFileID;//用户文件ID
@property (nonatomic, assign) NSInteger sex;//性别
@property (nonatomic, copy) NSString *loginID;//帐号ID
@property (nonatomic, copy) NSString *userName;//用户姓名
@property (nonatomic, copy) NSString *telephone;//用户电话
@property (nonatomic, copy) NSString *regularTelephone;//固定电话

@property (nonatomic, copy) NSString *yhm;//用户名


+ (instancetype)sharedUser;
+(instancetype)createInstance:(NSString*) usertype Dic:(NSDictionary *)userDic;
- (instancetype)initWithDict:(NSDictionary *)dict;
-(BOOL)isTeacher;
@end
