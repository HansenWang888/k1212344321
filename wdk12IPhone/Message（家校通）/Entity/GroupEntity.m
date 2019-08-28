#import "GroupEntity.h"
#import "DDUserEntity.h"
#import "NSDictionary+Safe.h"
#import "IMGroup.pb.h"
#import "DDDatabaseUtil.h"
#import "DDMessageEntity.h"
@implementation GroupEntity

- (void)setGroupUserIds:(NSMutableArray *)groupUserIds
{
    if (_groupUserIds)
    {
        _groupUserIds = nil;
        _fixGroupUserIds = nil;
    }
    _groupUserIds = groupUserIds;
    [groupUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addFixOrderGroupUserIDS:obj];
    }];
}
-(id)init{
    self = [super init];
    self.groupNicks = [NSMutableDictionary new];
    self.groupCreatorId = @"user_0";
    
    return self;
}
-(void)copyContent:(GroupEntity*)entity
{
    self.groupType = entity.groupType;
    self.lastUpdateTime = entity.lastUpdateTime;
    self.name = entity.name;
    self.avatar = entity.avatar;
    self.groupUserIds = entity.groupUserIds;
}

+(NSString *)getSessionId:(NSString *)groupId
{
     return groupId;
}
+(NSString *)pbGroupIdToLocalID:(uint64_t)groupID
{
    return [NSString stringWithFormat:@"%@%llu",GROUP_PRE,groupID];
}
+(int64_t)localGroupIDTopb:(NSString *)groupID
{
    if (![groupID hasPrefix:GROUP_PRE]) {
        return 0;
    }
    return [[groupID substringFromIndex:[GROUP_PRE length]] longLongValue];
}
+(GroupEntity *)initGroupEntityFromPBData:(GroupInfo *)groupInfo
{
    GroupEntity *group = [GroupEntity new];
    group.objID=[self pbGroupIdToLocalID:groupInfo.groupId];
    group.objectVersion=groupInfo.version;
    group.name=groupInfo.groupName;
    group.avatar = groupInfo.groupAvatar;
    group.groupCreatorId = [TheRuntime changeOriginalToLocalID:groupInfo.groupCreatorId SessionType:SessionTypeSessionTypeSingle];
    group.groupType = groupInfo.groupType;
    group.isShield=groupInfo.shieldStatus;
    NSMutableArray *ids  = [NSMutableArray new];
    for (int i = 0; i<[groupInfo.groupMemberList count]; i++) {
        [ids addObject:[TheRuntime changeOriginalToLocalID:[groupInfo.groupMemberList[i] integerValue] SessionType:SessionTypeSessionTypeSingle]];
    }
    group.groupUserIds = ids;
    group.lastMsg=@"";
    group.InContact=0;
    
    NSMutableDictionary* nicks = [NSMutableDictionary new];
    [groupInfo.groupNickList enumerateObjectsUsingBlock:^(GroupUserInfo* obj, NSUInteger idx, BOOL *stop) {
        NSString* uid = [TheRuntime changeOriginalToLocalID:obj.userId SessionType:SessionTypeSessionTypeSingle];
        [nicks setObject:obj.groupNick forKey:uid];
        
    //    NSLog(@"create group nick from pb:%@,%@ ",uid,obj.groupNick);
    }];
    group.groupNicks = nicks;
    return group;
}
- (void)addFixOrderGroupUserIDS:(NSString*)ID
{
    if (!_fixGroupUserIds)
    {
        _fixGroupUserIds = [[NSMutableArray alloc] init];
    }
    [_fixGroupUserIds addObject:ID];
}

+(GroupEntity *)dicToGroupEntity:(NSDictionary *)dic
{
    GroupEntity *group = [GroupEntity new];
    group.groupCreatorId=[dic safeObjectForKey:@"creatID"];
    group.objID = [dic safeObjectForKey:@"groupId"];
    group.avatar = [dic safeObjectForKey:@"avatar"];
    group.GroupType = [[dic safeObjectForKey:@"groupType"] integerValue];
    group.name = [dic safeObjectForKey:@"name"];
    group.avatar = [dic safeObjectForKey:@"avatar"];
    group.isShield = [[dic safeObjectForKey:@"isshield"] boolValue];
    NSString *string =[dic safeObjectForKey:@"Users"];
    NSMutableArray *array =[NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"-"]] ;
    if ([array count] >0) {
        group.groupUserIds=[array copy];
    }
    group.lastMsg =[dic safeObjectForKey:@"lastMessage"];
    group.objectVersion = [[dic safeObjectForKey:@"version"] integerValue];
    group.InContact = [[dic safeObjectForKey:@"InContact"] integerValue];
    group.lastUpdateTime=[[dic safeObjectForKey:@"lastUpdateTime"] longValue];
    [group nicksFromDBString:[dic safeObjectForKey:@"GroupNick"]];
    return group;
}
-(BOOL)theVersionIsChanged
{
    return YES;
}
-(void)updateGroupInfo
{
    
}
-(NSString*)nicksToDBString{

    if(_groupNicks == nil) return @"";

    IMGroupNickSerialBuilder* builder = [IMGroupNickSerial builder];
    [[_groupNicks allKeys]enumerateObjectsUsingBlock:^(NSString* uid, NSUInteger idx, BOOL *stop) {
        NSString * nick = [_groupNicks objectForKey:uid];
        if(nick == NULL||[nick isEqualToString:@""]) return ;
        GroupNickSerialInfoBuilder* infobuilder = [GroupNickSerialInfo builder];
        [infobuilder setUserId:uid];
        [infobuilder setGroupNick:[_groupNicks objectForKey:uid]];
        [builder addNicks:[infobuilder build]];
    }];
    NSData* data = [builder build].data;
    NSString* ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

    return ret;
}
-(void)nicksFromDBString:(NSString*)nickstr{
  
    _groupNicks = [NSMutableDictionary new];
    if(nickstr == nil) return;

    NSData* data = [nickstr dataUsingEncoding:NSUTF8StringEncoding];
    
    IMGroupNickSerial* serial = [IMGroupNickSerial parseFromData:data];

    if(serial){
        for(GroupNickSerialInfo* nickinfo in serial.nicks){
            NSString* uid = nickinfo.userId;
            NSString* nick = nickinfo.groupNick;
            [_groupNicks setObject:nick forKey:uid];
            
        }
    }
}
-(NSString*)getGroupNick:(NSString*) uid{

    NSString* ret = [_groupNicks objectForKey:uid];
    return ret;
}
-(void)setGroupNick:(NSString*) uid Nick:(NSString*)nick{
    [_groupNicks setObject:nick forKey:uid];
}
@end
