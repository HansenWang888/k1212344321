//
//  RuntimeStatus.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-31.
//  Copyright (c) 2014 dujia. All rights reserved.
//
#define TOPKEY @"fixedTop"
#define SHIELDINGKEY @"shieldingkey"
#import "RuntimeStatus.h"
#import "DDUserEntity.h"
#import "DDGroupModule.h"
#import "SubscribeEntity.h"
#import "std.h"
#import "DDMessageModule.h"
#import "DDClientStateMaintenanceManager.h"
//#import "LoginViewController.h"
//#import "DDAppDelegate.h"
#import "NSString+Additions.h"

#import "DDClientState.h"
#import "IMLogin.pb.h"

NSString* ImageFullUrl(NSString* url){
    if(url == nil || [url isEqualToString:@""]) return @"";
    NSString* rrr = TheRuntime.fastdfsdownload ;
    NSString* ret =  [TheRuntime.fastdfsdownload stringByAppendingString:url];
    
    return ret;
}

@interface RuntimeStatus()
@property(strong)NSMutableArray *userDefaults;
@property(strong)NSMutableArray *shieldingArray;

@end
@implementation RuntimeStatus

+ (instancetype)instance
{
    static RuntimeStatus* g_runtimeState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runtimeState = [[RuntimeStatus alloc] init];
        
    });
    return g_runtimeState;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = nil;
     
        NSLog(@"%@",[NSString documentPath]); //stringByAppendingPathComponent:@"/fixed.plist"]);
        self.userDefaults =[NSMutableArray arrayWithContentsOfFile:fixedlist];
   
        self.shieldingArray = [NSMutableArray arrayWithContentsOfFile:shieldinglist];
        self.fastdfsdownload=@"";
        self.fastdfsupload=@"";
        [self registerAPI];
        
    }
    return self;
}
-(void)registerAPI
{
    //接收踢出
//    ReceiveKickoffAPI *receiveKick = [ReceiveKickoffAPI new];
//    [receiveKick registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
//        KickReasonType type = [object integerValue];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"KickOffUser" object:@(type)];
//        
//    }
//     
//    ];
}
-(void)updateData
{
    [DDMessageModule shareInstance];
    [DDClientStateMaintenanceManager shareInstance];
    [DDGroupModule instance];
}
-(void)insertToFixedTop:(NSString *)idString
{
    
    
    
    if (self.userDefaults == nil || [self.userDefaults count] == 0) {
        self.userDefaults = [NSMutableArray new];
        [self.userDefaults addObject:idString];
       
    }else
    {
        if (![self.userDefaults containsObject:idString]) {
            [self.userDefaults addObject:idString];
            
        }
    }
    [self.userDefaults writeToFile:fixedlist atomically:YES];
}
-(void)removeFromFixedTop:(NSString *)idString
{
    
    if (self.userDefaults != nil) {
        [self.userDefaults removeObject:idString];
       
    }
     [self.userDefaults writeToFile:fixedlist atomically:YES];
    // [self.userDefaults synchronize];
}
-(BOOL)isInFixedTop:(NSString *)idString
{

    if (self.userDefaults == nil) {
        return NO;
    }else
    {
        if (![self.userDefaults containsObject:idString]) {
            return NO;
        }else
        {
            return YES;
        }
    }
    return NO;

}
-(NSUInteger)getFixedTopCount
{

    return [self.userDefaults count];
}
-(void)addToShielding:(NSString *)string
{
 
    
    if (self.shieldingArray == nil || [self.shieldingArray count] == 0) {
        self.shieldingArray =[NSMutableArray new];
        [self.shieldingArray addObject:string];
 
    }else
    {
        if (![self.shieldingArray containsObject:string]) {
            [self.shieldingArray addObject:string];
           // [self.userDefaults setObject:array forKey:SHIELDINGKEY];
        }
    }
    [self.shieldingArray writeToFile:shieldinglist atomically:YES];
    //[self.userDefaults synchronize];
}
-(void)removeIDFromShielding:(NSString *)idString
{
       if (self.shieldingArray != nil) {
        [self.shieldingArray removeObject:idString];
       // [self.userDefaults setObject:array forKey:SHIELDINGKEY];
    }
    //[self.userDefaults synchronize];
    [self.shieldingArray writeToFile:shieldinglist atomically:YES];
}
-(BOOL)isInShielding:(NSString *)idString
{
   // NSMutableArray *array = [self.userDefaults objectForKey:SHIELDINGKEY];
    if (self.shieldingArray == nil) {
        return NO;
    }else
    {
        if (![self.shieldingArray containsObject:idString]) {
            return NO;
        }else
        {
            return YES;
        }
    }
    return NO;
    
}
-(void)showAlertView:(NSString *)title Description:(NSString *)string
{

}
-(uint64_t)changeIDToOriginal:(NSString *)sessionID
{
    NSArray *array = [sessionID componentsSeparatedByString:@"_"];
    if (array[1]) {
        return [array[1] longLongValue];
    }
    return 0;
}
-(NSString *)changeOriginalToLocalID:(uint64_t)orignalID SessionType:(SessionType)sessionType
{
    if(sessionType == SessionTypeSessionTypeSingle)
    {
        return [DDUserEntity pbUserIdToLocalID:orignalID];
    }
    if(sessionType == SessionTypeSessionTypeSubscription)
    {
        return [SubscribeEntity pbSBIdToLocalID:orignalID];
    }
    return [GroupEntity pbGroupIdToLocalID:orignalID];
}
@end
