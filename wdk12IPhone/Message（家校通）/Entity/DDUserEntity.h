//
//  DDUserEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDBaseEntity.h"
#import "IMBaseDefine.pb.h"
#import "ContactInfo.h"
#define DD_USER_INFO_SHOP_ID_KEY                    @"shopID"
#define DEFAULT_AVATAR [UIImage imageNamed:@"defaultAvatar"]
@interface DDUserEntity : DDBaseEntity
@property(nonatomic,strong) NSString *name;         //用户名
@property(nonatomic,strong) NSString *nick;         //用户昵称
@property(nonatomic,strong) NSString *avatar;       //用户头像
@property(strong)NSString *ps;                       //个性签名
@property(strong)NSString* rmkname;                 //目前表示通讯录表内的beizhu
@property(strong)NSString *position;
@property(assign)NSInteger sex;

@property(strong)NSString *telphone;
@property(strong)NSString *email;
@property(strong)NSString *pyname;

@property(assign)NSInteger userStatus;
@property(assign)NSInteger InContact;
- (id)initWithUserID:(NSString*)userID ;
+(id)dicToUserEntity:(NSDictionary *)dic;
-(void)sendEmail;
-(void)callPhoneNum;
-(NSString *)getAvatarUrl;
-(NSString *)getAvatarPreImageUrl;
-(id)initWithPB:(UserInfo *)pbUser;

+(uint64_t)localIDTopb:(NSString *)userid;
+(NSString *)pbUserIdToLocalID:(uint64_t)userID;
-(void)updateLastUpdateTimeToDB;
@end