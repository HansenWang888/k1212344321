#import <Foundation/Foundation.h>
#import "DDBaseEntity.h"
#import "DDMessageEntity.h"
static NSString* const GROUP_PRE = @"group_";          //group id 前缀

enum
{
    GROUP_TYPE_FIXED = 1,       //固定群
    GROUP_TYPE_TEMPORARY,       //临时群
};

typedef enum
{
    GROUP_NOTIFY_MEMBER = 1,
    GROUP_NOTIFY_OTHER = 2
}GroupNotifyType;
@interface GroupEntity : DDBaseEntity

@property(copy) NSString *groupCreatorId;        //群创建者ID
@property(nonatomic,assign) int groupType;                //群类型
@property(nonatomic,strong) NSString* name;                  //群名称
@property(nonatomic,strong) NSString* avatar;                //群头像
@property(nonatomic,strong) NSMutableArray* groupUserIds;    //群用户列表ids
@property(nonatomic,readonly)NSMutableArray* fixGroupUserIds;//固定的群用户列表IDS，用户生成群头像
@property NSMutableDictionary* groupNicks;
@property(strong)NSString *lastMsg;
@property(assign)BOOL isShield;
@property(assign)NSInteger InContact;
-(void)copyContent:(GroupEntity*)entity;
+(int64_t)localGroupIDTopb:(NSString *)groupID;
+(NSString *)pbGroupIdToLocalID:(uint64_t)groupID;
- (void)addFixOrderGroupUserIDS:(NSString*)ID;
-(NSString*)nicksToDBString;
-(void)nicksFromDBString:(NSString*)nickstr;
-(NSString*)getGroupNick:(NSString*) uid;
-(void)setGroupNick:(NSString*) uid Nick:(NSString*)nick;
+(GroupEntity *)dicToGroupEntity:(NSDictionary *)dic;
+(NSString *)getSessionId:(NSString *)groupId;
+(GroupEntity *)initGroupEntityFromPBData:(GroupInfo *)groupInfo;
@end

