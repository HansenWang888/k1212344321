#import "ContactModule.h"

#import "AddFriend.h"
#import "AcceptFriend.h"
#import "DDUserEntity.h"
#import "DDUserModule.h"
#import "DDGroupModule.h"
#import "UserVerifyNotify.h"
#import "AcceptFriendNotify.h"
#import "ListVerify.h"
#import "VerifyEntity.h"
#import "RuntimeStatus.h"
#import "DDAllUserAPI.h"
#import "ContactInfo.h"
#import "DDUserDetailInfoAPI.h"
#import "GetGroupInfoAPi.h"
#import "DDDatabaseUtil.h"
#import "util.h"
#import "modifyContactAPI.h"
#import "DDNotificationHelp.h"
#import "FileLoadModule.h"
#import "GroupModifyNotify.h"
#import "IMBaseDefine.pb.h"
#import "SessionModule.h"
#import "SubscribeModule.h"
#import "SessionEntity.h"
#import "DenialVeify.h"
#import "DDClientState.h"
#import "ModifyUserInfo.h"
#import "SubscribeEntity.h"
#import "SearchUser.h"
#define DEFAULT_IMAGE_BODY @"../../images/morentouxiang.png"
#define DEFAULT_IMAGE_GIRL @"234.png"


@implementation  ContactModule
{
    NSMutableDictionary* _allVerify;
    NSMutableDictionary* _contact;
    dispatch_queue_t _updatecontact;

}
+ (instancetype)shareInstance
{
    static ContactModule* g_contactModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_contactModule = [[ContactModule alloc] init];
    });
    return g_contactModule;
}

-(instancetype)init
{
    self = [super init];
    if(self){

        _allVerify = [[NSMutableDictionary alloc]init];
        _contact = [NSMutableDictionary new];
        _updatecontact = dispatch_queue_create("com.jstx.updateusers", DISPATCH_QUEUE_CONCURRENT);
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContact) name:DDNotificationUserLoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFriendVerify) name:DDNotificationUserLoginSuccess object:nil];
        [self registerNotify];
    }
    return self;
}
-(void)registerNotify{
    
    //被加为好友
    AcceptFriendNotify* acceptFriendnotify = [AcceptFriendNotify new];
    [acceptFriendnotify registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        if(error) return ;
        NSString* fromid = object;
        ContactInfoEntity* centity = [_contact objectForKey:fromid];
        if(!centity) centity = [[ContactInfoEntity alloc]initWithUid:fromid];
        centity.status = 0;
        [_contact setObject:centity forKey:fromid];
        [[DDDatabaseUtil instance]insertContacts:@[centity] Block:^(NSError *error) {
            
        }];
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationContactRefresh object:nil];

        
    }];
    
    UserVerifyNotify* userVerifyNotify = [UserVerifyNotify new];
    [userVerifyNotify registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        if(error) return ;
        VerifyEntity* ventity = object;
        [_allVerify setObject:ventity forKey:ventity.objID];
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationVerifyListRefresh object:nil];
    }];
    
    
}
-(void)LoadContact:(ContactLoadCompeletion)block{
    [[DDDatabaseUtil instance]loadContact:^(NSArray *contact) {
        [self insertContact:contact];
        block();
        NSLog(@"local contact size:  %ld",_contact.count);
    }];
}
-(void)insertContact:(NSArray*) contact{
    [contact enumerateObjectsUsingBlock:^(ContactInfoEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_contact setObject:obj forKey:obj.objID];
    }];
}
-(void)refreshContact{
    
    DDAllUserAPI* api = [DDAllUserAPI new];
    [api requestWithObject:@[@(0)] Completion:^(id response, NSError *error) {
        
        NSArray* array = [response objectForKey:@"userlist"];
        if(!array || [array count]==0) return ;
        
        [_contact removeAllObjects];
        [[DDDatabaseUtil instance]removeAllContacts];
        [[DDDatabaseUtil instance]insertContacts:array Block:^(NSError *error) {
            
        }];
        
        [self insertContact:array];
        
        [DDNotificationHelp postNotification:DDNotificationContactRefresh userInfo:nil object:nil];
        
        NSMutableArray* losslist = [NSMutableArray new];
        [_contact enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ContactInfoEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
            if(obj.type == 1 && [[DDUserModule shareInstance]getUserByID:obj.objID] == nil){
                [losslist addObject:obj.objID];
            }
        }];
        [losslist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self getUserInfoWithNotification:obj ForUpdate:NO];
        }];
        
    }];
}


-(BOOL)IsContactUser:(NSString*)uid{
    ContactInfoEntity* centity = [_contact objectForKey:uid];
    if(centity && centity.type ==1 && centity.status == 0) return YES;
    return NO;
}
-(BOOL)IsContactGroup:(NSString*)gid{
    ContactInfoEntity* centity = [_contact objectForKey:gid];
    if(centity && centity.type ==2 && centity.status == 0) return YES;
    return NO;
}
-(NSMutableDictionary*)GetContact{
    
    return _contact;
}
-(NSMutableArray*)GetContactUser{
    NSMutableArray* ret = [NSMutableArray new];
    [_contact enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ContactInfoEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj isContactUser]){
            [ret addObject:obj];
        }
    }];
    return ret;
}
-(NSMutableArray*)GetContactGroup{
    NSMutableArray* ret = [NSMutableArray new];
    [_contact enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ContactInfoEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj isContactGroup]){
            [ret addObject:obj];
        }
    }];
    return ret;
}
-(ContactInfoEntity*)GetContactInfoByID:(NSString*)objid{
    return [_contact objectForKey:objid];
}

-(void)SearchUser:(NSString*)key Block:(SearchUserCompeletion)block{
    
    SearchUserAPI* searchuser = [[SearchUserAPI alloc]init];
    
    [searchuser requestWithObject:key Completion:^(id response, NSError *error) {
        if(!error){
            //NSLog(@"search user api respone :%ld",[response count]);
            
            NSMutableArray* ret = [NSMutableArray new];
            NSMutableArray* userlist = response[0];
            [userlist enumerateObjectsUsingBlock:^(DDUserEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![self IsContactUser:obj.objID] && ![obj.objID isEqualToString: TheRuntime.user.objID]){
                    [ret addObject:obj];
                }
                [[DDUserModule shareInstance]addMaintanceUser:obj];
            }];
            NSMutableArray* sblist = response[1];
            NSMutableArray* sbret = [NSMutableArray new];
            [sblist enumerateObjectsUsingBlock:^(SubscribeEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[SubscribeModule shareInstance]insertToModule:obj];
                if([[SubscribeModule shareInstance]getAttentionBySBID:obj.objID] == nil){
                    [sbret addObject:obj];
                }
            }];
            block(ret,sbret);
        }
        else{
            block(nil,nil);
        }
        
    }];
}
-(void)removeUserFromContact:(NSString*) uid Block:(ContactModifyCompeletion) block{
    
    ContactInfoEntity* centity = [self GetContactInfoByID:uid];
    if(!(centity && [centity isContactUser])){
        block([NSError errorWithDomain:@"not contact user" code:0 userInfo:nil]);
        return;
    }
    
    ModifyContactApi* api = [ModifyContactApi new];
    [api requestWithObject:@[@(1),uid,@(1)] Completion:^(id response, NSError *error) {
        if(!error ){
            NSInteger code =  [response integerValue];
            if(code == ContactModifyRetCodeOk){
                centity.status = 1;
                [[DDDatabaseUtil instance]insertContacts:@[centity] Block:^(NSError *error) {
                    
                }];
                
                SessionEntity* session =  [[SessionModule sharedInstance]getSessionById:uid];
                if(session) [[SessionModule sharedInstance]removeSessionByServer:session];
                block(nil);
                [DDNotificationHelp postNotification:DDNotificationUserUpdated userInfo:nil object:uid];
            }
            else{
                block([NSError errorWithDomain:@"removeUserFromContact" code:code userInfo:nil]);
            }
        }
        else{
            block(error);
        }
    }];
    
}
-(void)removeGroupFromContact:(NSString*) gid Block:(ContactModifyCompeletion) block{
    
    ContactInfoEntity* centity = [self GetContactInfoByID:gid];
    if(!(centity && [centity isContactGroup])){
        block([NSError errorWithDomain:@"not contact user" code:0 userInfo:nil]);
        return;
    }
    
    ModifyContactApi* api = [ModifyContactApi new];
    [api requestWithObject:@[@(2),gid,@(1)] Completion:^(id response, NSError *error) {
        if(!error ){
            NSInteger code =  [response integerValue];
            if(code == ContactModifyRetCodeOk){
                centity.status = 1;
                [[DDDatabaseUtil instance]insertContacts:@[centity] Block:^(NSError *error) {
                    
                }];
                block(nil);
            }
            else{
                block([NSError errorWithDomain:@"removegroupFromContact" code:code userInfo:nil]);
            }
        }
        else{
            block(error);
        }
    }];
}
-(void)addUserToContact:(NSString*)uid Block:(ContactModifyCompeletion)block{
    ContactInfoEntity* centity = [self GetContactInfoByID:uid];
    if(centity && [centity isContactUser]){
        block(nil);
        return;
    }
    ModifyContactApi* api = [ModifyContactApi new];
    [api requestWithObject:@[@(1),uid,@(0)] Completion:^(id response, NSError *error) {
        if(!error){
            NSInteger code = [response integerValue];
            if(code == ContactModifyRetCodeOk){
                ContactInfoEntity* centity = [self GetContactInfoByID:uid];
                if(!centity) {
                    centity = [[ContactInfoEntity alloc]initWithUid:uid];
                    [self insertContact:@[centity]];
                }
                
                centity.status = 0;
                [[DDDatabaseUtil instance]insertContacts:@[centity] Block:^(NSError *error) {
                    
                }];
                block(nil);
                [DDNotificationHelp postNotification:DDNotificationUserUpdated userInfo:nil object:uid];
                
            }
            else{
                block([NSError errorWithDomain:@"addUserToContact" code:code userInfo:nil]);
            }
        }
        else{
            block(error);
        }
        
    }];
}
-(void)addGroupToContact:(NSString*)gid Block:(ContactModifyCompeletion)block{
    ContactInfoEntity* centity = [self GetContactInfoByID:gid];
    if(centity && [centity isContactGroup]){
        block(nil);
        return;
    }
    ModifyContactApi* api = [ModifyContactApi new];
    [api requestWithObject:@[@(2),gid,@(0)] Completion:^(id response, NSError *error) {
        if(!error){
            NSInteger code = [response integerValue];
            if(code == ContactModifyRetCodeOk){
                ContactInfoEntity* centity = [self GetContactInfoByID:gid];
                if(!centity) {
                    centity = [[ContactInfoEntity alloc]initWithGid:gid ];
                    [self insertContact:@[centity]];
                }
                
                centity.status = 0;
                [[DDDatabaseUtil instance]insertContacts:@[centity] Block:^(NSError *error) {
                    
                }];
                block(nil);
            }
            else{
                block([NSError errorWithDomain:@"addGroupToContact" code:code userInfo:nil]);
            }
        }
        else{
            block(error);
        }
        
    }];

}
-(void)modifyRmkname:(NSString*)uid Value:(NSString*)value Block:(ContactModifyCompeletion)block{
    ContactInfoEntity* centity = [self GetContactInfoByID:uid];
    if(!(centity && [centity isContactUser])){
        block(nil);
        return;
    }
    ModifyUserInfoApi* api = [ModifyUserInfoApi new];
    id _inobj = @[@(UserModifyTypeRemark),value,uid];
    [api requestWithObject:_inobj Completion:^(id response, NSError *error) {
        if(!error){
            centity.rmkname =value;
            [[DDDatabaseUtil instance]insertContacts:@[centity] Block:^(NSError *error) {
                
            }];
            block(nil);
            [DDNotificationHelp postNotification:DDNotificationUserUpdated userInfo:nil object:uid];
        }
        else{
            block(error);
        }
    }];
}




#pragma mark verify
-(void)refreshFriendVerify{
    
    ListVerifyAPI* api = [ListVerifyAPI new];
    [api requestWithObject:nil Completion:^(id response, NSError *error) {
        if(!error){
            [_allVerify removeAllObjects];
            NSMutableArray* verifylist = response;
            [verifylist enumerateObjectsUsingBlock:^(VerifyEntity*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [_allVerify setObject:obj forKey:obj.objID];
            }];
            
            if(verifylist.count >0 ){

                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationVerifyListRefresh object:nil];
            }
        }
    }];
}
-(NSArray*)getAllVerify{
    return [_allVerify allValues];
}
- (VerifyEntity *)getVerifyWithVerifyID:(NSString *)verifyID {
    return [_allVerify objectForKey:verifyID];
}
-(void)addFrindVerify:(NSString*)uid Verify:(NSString*)verify Block:(ContactModifyCompeletion)block{
    AddFriendApi* api = [AddFriendApi new];
    [api requestWithObject:@[uid,verify] Completion:^(id response, NSError *error) {
        if(!error){
            VerifyRet code = [response integerValue];
            if(code == VerifyRetVerifyOk || code == VerifyRetVerifyAlreadyInContact){
                block(nil);
            }
            else{
                block([NSError errorWithDomain:@"addFrindVerify" code:code userInfo:nil]);
            }
        }
        else{
            block(error);
        }
    }];
}
-(void)acceptFriendVerify:(VerifyEntity*)ventity Block:(ContactModifyCompeletion)block{

    AcceptFriendAPI* api = [AcceptFriendAPI new];
    [api requestWithObject:ventity.objID Completion:^(id response, NSError *error) {
        if(!error) {
            
            NSInteger code = [response integerValue];

            if(code == VerifyRetVerifyOk || code == VerifyRetVerifyAlreadyInContact){
                [_allVerify removeObjectForKey:ventity.objID];
                
                ContactInfoEntity* centity = [self GetContactInfoByID:ventity.objID];
                if(!centity) centity = [[ContactInfoEntity alloc]initWithUid:ventity.objID];
                centity.status = 0;
                [_contact setObject:centity forKey:ventity.objID];
                [[DDDatabaseUtil instance]insertContacts:@[centity] Block:^(NSError *error) {
                    
                }];
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserUpdated object:ventity.objID];
                block(nil);
                
                [self getUserInfoWithNotification:ventity.objID ForUpdate:NO];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationVerifyListRefresh object:nil];
            }
            else{
                block([NSError errorWithDomain:@"acceptFriendVerify" code:code userInfo:nil]);
            }
        }
        else{
            block(error);
        }
        
        
        
    }];
    
    
}
-(void)denialFriendVerify:(VerifyEntity*)ventity Block:(ContactModifyCompeletion)block{
    DenialVerifyApi* api = [DenialVerifyApi new];
    [_allVerify removeObjectForKey:ventity.objID];
    [api requestWithObject:ventity.objID Completion:^(id response, NSError *error) {
        
        
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationVerifyListRefresh object:nil];

    block(nil);
}
#pragma mark tools
-(void)GetUserInfoInqueueWithNotify:(NSArray*)lsuid;{
    //表示所有正在获取的用户
    static NSMutableDictionary* _inqueueuser = nil;
    //表一一个获取操作的用户集合
    static NSMutableArray* _userCache = nil;
    if(!_inqueueuser) _inqueueuser = [NSMutableDictionary new];
    if(!_userCache)   _userCache = [NSMutableArray new];
    //如果集合空
    if(_userCache.count == 0){
        [lsuid enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![_inqueueuser objectForKey:obj]){
                [_inqueueuser setObject:@"" forKey:obj];
                [_userCache addObject:obj];
            }
        }];
        //用户攒多了直接开始
        if(_userCache.count > 20){
            //倾倒缓存
            NSMutableArray* tmpbuffer = [[NSMutableArray alloc]initWithArray:_userCache];
            
            [_userCache removeAllObjects];
            
            [self GetUsersInfoFromServer:tmpbuffer Block:^(NSError *error, NSArray *userlist) {
                [self notifyUsersUpdate:userlist];
                
                [tmpbuffer enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [_inqueueuser removeObjectForKey:obj];
                }];
            }];
            
        }
        //延迟2秒开始
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSMutableArray* tmpbuffer = [[NSMutableArray alloc]initWithArray:_userCache];
                [_userCache removeAllObjects];
                [self GetUsersInfoFromServer:tmpbuffer Block:^(NSError *error, NSArray *userlist) {
                    [self notifyUsersUpdate:userlist];
                    
                    [tmpbuffer enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [_inqueueuser removeObjectForKey:obj];
                    }];
                }];
            });
        }
    }
    //缓存非空表示正有一个2秒延时请求，直接放入即可
    else{
        [lsuid enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![_inqueueuser objectForKey:obj]){
                [_inqueueuser setObject:@"" forKey:obj];
                [_userCache addObject:obj];
            }
        }];
        //用户攒多了直接开始
        if(_userCache.count > 20){
            //倾倒缓存
            NSMutableArray* tmpbuffer = [[NSMutableArray alloc]initWithArray:_userCache];
            
            [_userCache removeAllObjects];
            
            [self GetUsersInfoFromServer:tmpbuffer Block:^(NSError *error, NSArray *userlist) {
                [self notifyUsersUpdate:userlist];
                
                [tmpbuffer enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [_inqueueuser removeObjectForKey:obj];
                }];
            }];
            
        }
    }


}
-(void)notifyUsersUpdate:(NSArray<DDUserEntity*>*) users{
    if(users == nil) return;
    [users enumerateObjectsUsingBlock:^(DDUserEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserUpdated object:obj.objID];
        
    }];
}
-(void)GetUsersInfoFromServer:(NSArray *)lsuid Block:(UsersInfoCompeletion)block{
    if(lsuid.count == 0) block(nil,@[]);
    DDUserDetailInfoAPI* api = [[DDUserDetailInfoAPI alloc ]init];
    [api requestWithObject:lsuid Completion:^(id response, NSError *error) {
        if(!error){
            NSMutableArray* array = response;
            if(!array.count) {
                block([NSError errorWithDomain:@"GetUsersInfoFromServer" code:0 userInfo:nil],nil);
                return ;
            }
            [[DDDatabaseUtil instance]insertAllUser:array completion:^(NSError *error) {
                
            }];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[DDUserModule shareInstance]addMaintanceUser:obj];
            }];
            block(nil,array);
        }
        else{
            block(error,nil);
        }
    }];
}

-(DDUserEntity*)getUserInfoWithNotification:(NSString *)uid ForUpdate:(BOOL)update{
    assert(uid);
    DDUserEntity* uentity = [[DDUserModule shareInstance]getUserByID:uid];
    if(uentity == nil || update){
        [self GetUserInfoInqueueWithNotify:@[uid]];
    }
    return uentity;
}
-(void)getGroupMembersFromServerWithNotify:(GroupEntity*)gentity {
    NSMutableArray* losslist = [NSMutableArray new];
    
    [gentity.groupUserIds enumerateObjectsUsingBlock:^(NSString*  _Nonnull uid, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![[DDUserModule shareInstance]getUserByID:uid]){
            [losslist addObject:uid];
        }
    }];
    
    if(losslist.count >0){
        [self GetUserInfoInqueueWithNotify:losslist];
    }
}

#pragma mark theruntimeuser
-(void)updateAvatar:(NSString*)fileID{
    if([TheRuntime.user.avatar isEqualToString:fileID]) return;
    NSDictionary* dic = @{@"httpurl":fileID};
    NSData* jsondata = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    if(jsondata == nil) return;
    
    NSString* avatar = [[NSString alloc]initWithData:jsondata encoding:NSUTF8StringEncoding];
    if(avatar == nil) return;
    
    [self _changeselfinfo:avatar TYPE:UserModifyTypeAvatar Addation:nil Block:^(NSError *error, NSInteger responetime) {
        if(!error) {
            TheRuntime.user.avatar = fileID;
            TheRuntime.user.lastUpdateTime = responetime;
        }
    }];
}
-(void)updatePS:(NSString*)ps{
    [self _changeselfinfo:ps TYPE:UserModifyTypePs Addation:nil Block:^(NSError *error, NSInteger responetime) {
        if(!error) {
            TheRuntime.user.ps = ps;
            TheRuntime.user.lastUpdateTime = responetime;
        }
    }];
}
-(void) _changeselfinfo:(NSString*) value TYPE:(UserModifyType) TYPE Addation: (NSString*) addation Block:(ModifySelfCompeletion)block{
    
    
    ModifyUserInfoApi* api = [ModifyUserInfoApi new];
    id _inobj = nil;
    if(TYPE == UserModifyTypeNick){
        _inobj = @[@(TYPE),value,addation];
    }
    else{
        _inobj = @[@(TYPE),value];
    }
    [api requestWithObject:_inobj Completion:^(id response, NSError *error) {
        if(!error){
            block(nil,[response integerValue]);
        }
        else{
            block(error,0);
        }
        
    }];
}




-(void)clear{
    [_contact removeAllObjects];
    [_allVerify removeAllObjects];
}
@end
