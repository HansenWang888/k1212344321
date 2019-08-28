

#import "GroupModifyNotify.h"



#import "IMGroup.pb.h"
#import "DDUserEntity.h"
#import "DDGroupModule.h"
#import "GroupEntity.h"
@implementation GroupModiftNotify
- (int)responseServiceID
{
    return SERVICE_GROUP;
}

- (int)responseCommandID
{
    return GroupCmdIDCidGroupInfoChangeNotify;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
        
        IMGroupInfoChangeNotify* notify = [IMGroupInfoChangeNotify parseFromData:data];
        
        NSString* uid = [DDUserEntity pbUserIdToLocalID:notify.userId];
        NSString* gid = [GroupEntity pbGroupIdToLocalID:notify.groupId];
        NSInteger type = notify.changeType;
        NSString* value = notify.value;
        return @[uid,gid,@(type),value];
    };
    return analysis;
}
@end
