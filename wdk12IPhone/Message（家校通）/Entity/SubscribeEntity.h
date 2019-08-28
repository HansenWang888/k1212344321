//
//  SubscribeEntity.h
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDBaseEntity.h"
@class SubscribeInfo;
@interface SubscribeEntity : DDBaseEntity
@property NSString* name;
@property NSString* introduce;
@property NSString* fkbh;
@property NSString* avatar;
@property NSString* uuid;
@property NSString* subject;//主体类型
-(id)initWithPB:(SubscribeInfo*)sbinfo;
+(NSString *)pbSBIdToLocalID:(uint64_t)sbid;
@end

