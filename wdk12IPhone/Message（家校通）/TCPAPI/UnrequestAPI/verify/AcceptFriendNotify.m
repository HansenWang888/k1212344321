

#import "AcceptFriendNotify.h"



#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
#import "RuntimeStatus.h"
@implementation AcceptFriendNotify
- (int)responseServiceID
{
    return MODULE_ID_SESSION;
}

- (int)responseCommandID
{
    return BuddyListCmdIDCidAcceptFriendNotift;
}
//这里实现的很奇葩，又可能是别人接受了你，也有可能是你接受了别人
- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
        
        IMAcceptFriendNotify *notify = [IMAcceptFriendNotify parseFromData:data];
        NSString* fromid = [DDUserEntity pbUserIdToLocalID:notify.fromId]; //接受者
        NSString* userid = [DDUserEntity pbUserIdToLocalID:notify.userId]; //被接受者
        NSString* ret = nil;
        if([fromid isEqualToString: TheRuntime.userID]){
            ret = userid;
        }
        else{
            ret = fromid;
        }
        return ret;
    };
    return analysis;
}
@end
