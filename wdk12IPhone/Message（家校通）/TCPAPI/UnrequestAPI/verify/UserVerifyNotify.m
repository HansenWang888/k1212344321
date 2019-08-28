

#import "UserVerifyNotify.h"



#import "IMBuddy.pb.h"
#import "DDUserEntity.h"
#import "VerifyEntity.h"
@implementation UserVerifyNotify
- (int)responseServiceID
{
    return MODULE_ID_SESSION;
}

- (int)responseCommandID
{
    return BuddyListCmdIDCidAddFriendNotify;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
        
        IMAddFriendNotify *notify = [IMAddFriendNotify parseFromData:data];
        NSString* userid = [DDUserEntity pbUserIdToLocalID:notify.userId];
        
        VerifyEntity* entity = [[VerifyEntity alloc]initWithPB:notify.verifyinfo];
        
        
        return entity;
    };
    return analysis;
}
@end
