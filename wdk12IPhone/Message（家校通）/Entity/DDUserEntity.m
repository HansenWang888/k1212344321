//
//  DDUserEntity.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDUserEntity.h"
#import "NSDictionary+Safe.h"
//#import "PublicProfileViewControll.h"
#define USER_PRE @"user_"
#import "DDDatabaseUtil.h"
#import "IMBuddy.pb.h"
@implementation DDUserEntity
- (id)initWithUserID:(NSString*)userID
{
    self = [super init];
    if (self)
    {
        self.objID = [userID copy];
        _name = @"";
        _nick = @"";
        _ps = @"";
        _pyname = @"";
        _telphone = @"";
        _email =@"";
        _avatar = @"";

        self.lastUpdateTime = 0;
    }
    return self;
}
//- (NSString*)avatar
//{
//    if (![_avatar hasSuffix:@"_100x100"])
//    {
//        return [NSString stringWithFormat:@"%@_100x100",_avatar];
//    }
//    return _avatar;
//}



//@"serverTime":@(serverTime),
//@"result":@(loginResult),
//@"state":@(state),
//@"nickName":nickName,
//@"userId":userId,
//@"title":title,
//@"position":position,
//@"isDeleted":@(isDeleted),
//@"sex":@(sex),
//@"departId":departId,
//@"jobNum":@(jobNum),
//@"telphone":telphone,
//@"email":email,
//@"creatTime":@(creatTime),
//@"updateTime":@(updateTime),
//@"token":token,
//@"userType":@(userType)
+(id)dicToUserEntity:(NSDictionary *)dic
{
    DDUserEntity *user = [DDUserEntity new];
    user.objID = [dic safeObjectForKey:@"userId"];
    user.name = [dic safeObjectForKey:@"name"];
    user.nick = [dic safeObjectForKey:@"nickName"]?[dic safeObjectForKey:@"nickName"]:user.name;
    user.rmkname = [dic safeObjectForKey:@"rmkname"];
    
    user.avatar = [dic safeObjectForKey:@"avatar"];
   // user.department = [dic safeObjectForKey:@"department"];
  //  user.departId =[[dic safeObjectForKey:@"departId"] integerValue];
    user.ps = [dic safeObjectForKey:@"ps"];
    user.email = [dic safeObjectForKey:@"email"];
    user.position = [dic safeObjectForKey:@"position"];
    user.telphone = [dic safeObjectForKey:@"telphone"];
    user.sex = [[dic safeObjectForKey:@"sex"] integerValue];
    user.lastUpdateTime = [[dic safeObjectForKey:@"lastUpdateTime"] integerValue];
    user.pyname = [dic safeObjectForKey:@"pyname"];
    user.InContact = [[dic safeObjectForKey:@"InContact"] integerValue];

    return user;

}
-(void)sendEmail
{
    NSString *stringURL =[NSString stringWithFormat:@"mailto:%@",self.email];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}
-(void)callPhoneNum
{
    NSString *string = [NSString stringWithFormat:@"tel:%@",self.telphone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }else if([self class] != [other class])
    {
        return NO;
    }else {
        DDUserEntity *otherUser = (DDUserEntity *)other;
        if (![otherUser.objID isEqualToString:self.objID]) {
            return NO;
        }
        if (![otherUser.name isEqualToString:self.name]) {
            return NO;
        }
        if (![otherUser.nick isEqualToString:self.nick]) {
            return NO;
        }
        if (![otherUser.pyname isEqualToString:self.pyname]) {
            return NO;
        }
    }
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger objIDHash = [self.objID hash];
    NSUInteger nameHash = [self.name hash];
    NSUInteger nickHash = [self.nick hash];
    NSUInteger pynameHash = [self.pyname hash];
    
    return objIDHash^nameHash^nickHash^pynameHash;
}
+(NSString *)pbUserIdToLocalID:(uint64_t)userID
{
    return [NSString stringWithFormat:@"%@%llu",USER_PRE,userID];
}
+(uint64_t)localIDTopb:(NSString *)userid
{
    if (![userid hasPrefix:USER_PRE]) {
        return 0;
    }
    return [[userid substringFromIndex:[USER_PRE length]] longLongValue];
}

-(id)initWithPB:(UserInfo *)pbUser
{
    self = [super init];
    if (self) {
        self.objID = [[self class] pbUserIdToLocalID:pbUser.userId];
        self.name  = pbUser.userRealName;
        self.nick  = pbUser.userNickName;
        
        NSString* finalavatar = pbUser.avatarUrl;
        do{
            NSData* avatardata = [pbUser.avatarUrl dataUsingEncoding:NSUTF8StringEncoding];
            if(avatardata == nil) break;
            
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:avatardata options:NSJSONReadingAllowFragments error:nil];
            if(dic == nil) break;
            
            NSString* fid = [dic objectForKey:@"httpurl"];
            if(fid == nil) break;
            
            finalavatar = fid;
            
        }while(0);
        

        self.avatar= finalavatar;
      //  self.departId = pbUser.departmentId;
        self.ps = pbUser.ps;
        self.telphone = pbUser.userTel;
        self.sex =   pbUser.userGender;
        self.email = pbUser.email;
        self.pyname = pbUser.userDomain;
        self.userStatus = pbUser.status;
        self.lastUpdateTime = pbUser.latestUpdateTime;
        self.InContact = 0;
    }
    
    return self;
}

-(NSString*)avatarFullUrl{
    return [TheRuntime.fastdfsdownload stringByAppendingPathComponent:_avatar];
}
-(NSString *)getAvatarUrl
{
    return [NSString stringWithFormat:@"%@_100x100.jpg",self.avatar];
}
-(NSString *)getAvatarPreImageUrl
{
    return [NSString stringWithFormat:@"%@_640×999.jpg",self.avatar];
}
@end
