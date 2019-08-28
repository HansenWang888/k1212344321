#import "nameLabel.h"
#import "DDUserModule.h"
#import "GroupEntity.h"
#import "DDGroupModule.h"
#import "contactModule.h"
#import "SubscribeModule.h"
#import "SubscribeEntity.h"
@implementation NameLabel
{
    NSString* _uid;
    NSString* _gid;
    NSString* _sbid;
}
-(void)setSBID:(NSString*)sbid{
    assert(_gid == nil);
    assert(_uid == nil);
    if([_sbid isEqualToString:sbid]) return;
    _sbid = sbid;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subscribeUpdate:) name:DDNotificationSubscribeInfoUpdate object:nil];
    
    [self subscribeUpdateImpl:_sbid];
}
-(void)setUid:(NSString*)uid{
    assert(_gid == nil);
    if([_uid isEqualToString:uid]) return;
    _uid = uid;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userUpdate:) name:DDNotificationUserUpdated object:nil];
    [self userUpdateImpl:uid];
}
-(void)setGid:(NSString*)gid{
    assert(_uid == nil);
    if([_gid isEqualToString:gid]) return;
    _gid = gid;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(groupUpdate:) name:DDNotificationGroupUpdated object:nil];
    [self groupUpdateImpl:gid];
}
-(void)setUid:(NSString*)uid WithGID:(NSString*)gid{
    if([gid isEqualToString:_gid ]&& [uid isEqualToString:_uid] ) return;
    _uid = uid;
    _gid = gid;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self groupUserNickUpdateImpl:uid GID:gid];
}
-(void)userUpdate:(NSNotification*)notification{
    if([notification.object isEqualToString:_uid]){
        [self userUpdateImpl:notification.object];
    }
}
-(void)groupUpdate:(NSNotification*)notification{
    
    NSString* gid = [notification.object objectAtIndex:0];
    GroupNotifyType type = [[notification.object objectAtIndex:1] integerValue];
    if(type & GROUP_NOTIFY_OTHER && [gid isEqualToString:_gid]){
        [self groupUpdateImpl:gid];
    }
    
}
-(void)groupUpdateImpl:(NSString*)gid{
    GroupEntity* gentity = [[DDGroupModule instance]getGroupByGId:gid];
    if(gentity){
        self.text = gentity.name;
    }
}
-(void)userUpdateImpl:(NSString*)uid{
    DDUserEntity* uentity = [[DDUserModule shareInstance]getUserByID:uid];
    ContactInfoEntity* centity = [[ContactModule shareInstance]GetContactInfoByID:uid];
    NSString* text = nil;
    if(uentity){
        text = uentity.nick;
    }
    if(centity && [centity hasRmkname]){
        text = centity.rmkname;
    }
    self.text = text;
}
-(void)subscribeUpdate:(NSNotification*)notify{
    NSString* sbuuid = notify.object[0];
    if(![sbuuid isEqualToString:_sbid]) return;
    SubscribeUpdateType type = [notify.object[1] integerValue];
    if(type != SubscribeUpdateTypeInfo) return;
    [self subscribeUpdateImpl:_sbid];
}
-(void)subscribeUpdateImpl:(NSString*)sbid{
    SubscribeEntity* sbentity = [[SubscribeModule shareInstance]getSubscribeBySBID:sbid];
    
    if(sbentity != nil){
        self.text = sbentity.name;
    }
    else {
        self.text = @"";
    }
}
-(void)groupUserNickUpdateImpl:(NSString*)uid GID:(NSString*)gid{
    GroupEntity* gentity = [[DDGroupModule instance]getGroupByGId:gid];
    if(gentity){
        NSString* gnick = [gentity getGroupNick:uid];
        if(gnick && ![gnick isEqualToString:@""]){
            self.text = gnick;
        }
        else{
            [self userUpdateImpl:uid];
        }
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end