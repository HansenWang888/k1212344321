//
//  SubscribeEntity.m
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "SubscribeEntity.h"
#define SB_PRE @"sb_"
@implementation SubscribeEntity
-(id)initWithPB:(SubscribeInfo*)sbinfo{
    self = [super init];
    self.objID = [SubscribeEntity pbSBIdToLocalID:sbinfo.sbId];
    self.uuid = sbinfo.sbUuid;
    self.name = sbinfo.sbName;
    self.avatar = sbinfo.sbAvatar;
    self.introduce = sbinfo.sbIntroduce;
    self.fkbh = sbinfo.sbFkbh;
    self.subject = sbinfo.sbSubject;
    return self;
}
+(NSString *)pbSBIdToLocalID:(uint64_t)sbid{
     return [NSString stringWithFormat:@"%@%llu",SB_PRE,sbid];
}
@end



