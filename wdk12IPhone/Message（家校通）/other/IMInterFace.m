//
//  IMInterFace.m
//  wdk12pad
//
//  Created by macapp on 15/12/31.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import "IMInterFace.h"
#import "LoginModule.h"
#import "DDTcpClientManager.h"
#import "DDClientState.h"
#import "SessionModule.h"
#import "ContactModule.h"
#import "DDGroupModule.h"
#import "DDUserModule.h"
#import "SubscribeModule.h"
#import "DDClientStateMaintenanceManager.h"
void IM_Login(){

    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    
    
    [userdefault setObject:IM_URL forKey:@"ipaddress"];
    NSString* loginid = [WDUser sharedUser].loginID;
    NSString* userkey = [NSString stringWithFormat:@"IM_loginid_%@",loginid];
    NSString* uid = [userdefault objectForKey:userkey] ;
    //uid = nil;
    [DDUserModule shareInstance];
    [DDGroupModule instance];
    [ContactModule shareInstance];
    [SubscribeModule shareInstance];
    [SessionModule sharedInstance];
    if(uid){
        [[LoginModule instance]offlineLogin:loginid UID:uid success:^(DDUserEntity *user) {
            
        } failure:^(NSString *error) {
            
        }];
    }
    else{

        [[LoginModule instance]setLoginUname:loginid];
        [DDClientStateMaintenanceManager shareInstance];
        [DDClientState shareInstance].userState = DDUserOffLine;
    }


  //  [DDClientState shareInstance].userState = DDUserOffLine;

}
void IM_Logout(){
    
    [DDClientState shareInstance].userState = DDUserOffLineInitiative ;
    [[DDTcpClientManager instance]disconnect];
    [[SessionModule sharedInstance]clear];
    [[ContactModule shareInstance]clear];
    [[DDGroupModule instance]clear];
    [[SubscribeModule shareInstance] clear];
}
