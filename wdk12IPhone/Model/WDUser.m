//
//  WDUser.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/25.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDUser.h"
#import "WDHTTPManager.h"
#import "WDTeacher.h"
#import "WDParent.h"

#import "NSDictionary+R.h"

static WDUser* userInstance = nil;

@implementation WDUser

+ (instancetype)sharedUser {
    return userInstance;
}

+(instancetype)createInstance:(NSString*) usertype Dic:(NSDictionary *)userDic{
    WDUser* user = nil;
    if([usertype isEqualToString:@"01"]) {
        user = [[WDTeacher alloc]initWithDict:userDic];
    }
    else {
        user = [[WDParent alloc]initWithDict:userDic];
    }
    if(user) {
        user.userType = usertype;
        userInstance = user;
    }
    return user;
}

-(BOOL)isTeacher{
    return NO;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.nickName = [dict recursiveObjectForKey:@"nc"];
        self.PS = [dict recursiveObjectForKey:@"gxqm"];
        self.avatar = [dict recursiveObjectForKey:@"tx"];
        self.avatarFileID = [dict recursiveObjectForKey:@"txid"];
        self.loginID = [dict recursiveObjectForKey:@"zh"];
        self.userName = [dict recursiveObjectForKey:@"xm"];
        self.sex = [[dict recursiveObjectForKey:@"xb"] intValue];
        self.telephone = [dict recursiveObjectForKey:@"yddh"];
        self.email = [dict recursiveObjectForKey:@"dzyx"];
        self.regularTelephone = [dict recursiveObjectForKey:@"gddh"];
        self.userID = [dict recursiveObjectForKey:@"zh"];
        self.yhm = [dict recursiveObjectForKey:@"yhm"];
    }
    return  self;
}
@end
