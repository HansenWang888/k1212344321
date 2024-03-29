//
//  NotificationHelp.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDNotificationHelp.h"

//NSString* const notificationLoginMsgServerSuccess = @"Notification_Login_Msg_Server_Success";
//NSString* const notificationLoginMsgServerFailure = @"Notification_Login_Msg_Server_Success";
NSString* const DDNotificationRemoveSession = @"Notification_Remove_Session";
//NSString* const notificationLoginLoginServerSuccess = @"Notification_login_login_server_success";
//NSString* const notificationLoginLoginServerFailure = @"Notification_login_login_server_failure";
NSString* const DDNotificationTcpLinkConnectComplete = @"Notification_Tcp_Link_connect_complete";
NSString* const DDNotificationTcpLinkConnectFailure = @"Notification_Tcp_Link_conntect_Failure";
NSString* const DDNotificationTcpLinkDisconnect = @"Notification_Tcp_link_Disconnect";
NSString* const DDNotificationStartLogin = @"Notification_Start_login";
NSString* const DDNotificationServerHeartBeat = @"Notification_Server_heart_beat";
NSString* const DDNotificationUserLoginSuccess = @"Notification_user_login_success";

NSString *const DDNotificationLogout =
    @"Notification_user_logout";
NSString* const DDNotificationUserLoginFailure = @"Notification_user_login_failure";
NSString* const DDNotificationUserReloginSuccess = @"Notification_user_relogin_success";
NSString* const DDNotificationUserOffline = @"Notification_user_off_line";
NSString* const DDNotificationUserKickouted = @"Notification_user_kick_out";
NSString* const DDNotificationUserInitiativeOffline = @"Notification_user_initiative_Offline";
NSString* const DDNotificationReloadTheRecentContacts = @"Notification_reload_recent_contacts";

//NSString* const notificationGetAllUsers = @"Notification_get_all_Users";
NSString* const DDNotificationReceiveMessage = @"Notification_receive_message";
NSString* const DDNotificationReceiveP2PShakeMessage = @"Notification_receive_P2P_Shake_message";
NSString* const DDNotificationReceiveP2PInputingMessage = @"Notifictaion_receive_P2P_Inputing_message";
NSString* const DDNotificationReceiveP2PStopInputingMessage = @"Notification_receive_P2P_StopInputing_message";
NSString* const DDNotificationLoadLocalGroupFinish = @"Notification_local_group";

//---------------------------------------------------------------------------------------------------
NSString* const DDNotificationRecentContactsUpdate = @"Notification_RecentContactsUpdate";
NSString* const DDNotificationLocalPrepared =
    @"Notification_LocalPrepared";
NSString* const DDNotificationContactRefresh =
    @"Notification_ContactRefresh";
NSString* const DDNotificationUserUpdated=
    @"Notification_UserUpdated";
NSString* const DDNotificationRequestOpenSession=
    @"Notification_OpenSession";

NSString* const DDNotificationVerifyListRefresh =
@"Notification_VerifyListRefresh";

NSString* const DDNotificationSessionCreated =
@"Notification_SessionCreated";
NSString* const DDNotificationSessionUpdated=
@"Notification_SessionUpdated";
NSString* const DDNotificationSubscribeAbstractUpdate =
@"Notification_SubscribeAbstructUpdate";
NSString* const DDNotificationGroupUpdated=
@"Notification_GroupUpdated";
NSString* const DDNotificationSessionRemove=
@"Notification_SessionRemove";
NSString* const DDNotificationMessageSendingStateChanged=@"DDNotification_MessageSendingStateChanged";
NSString* const DDNotificationSessionReciveMessage = @"DDNotification_ReciveMessage";
NSString* const DDNotificationResendMessage=
    @"DDNotification_ResendMessage";
NSString* const DDNotificationSubscribeInfoUpdate = @"DDNotificationSubscribeInfoUpdate";
NSString* const DDNotificationReqeustHyperLink=
    @"DDNotificationReqeustHyperLink";
NSString* const DDNotificationRequestHtmlString=@"DDNotificationRequestHtmlString";
NSString* const DDNotificationRequestOpenFile =
    @"DDNotificationRequestOpenFile";
NSString *const DDNotificationCancleAttention = @"DDNotificationCancleAttention";
NSString *const DDNotificationAttentionSuccessful = @"DDNotificationAttentionSuccessful";
NSString* const DDNotificationContactUpdateGroup = @"DDNotificationContactUpdateGroup";
@implementation DDNotificationHelp
+ (void)postNotification:(NSString*)notification userInfo:(NSDictionary*)userInfo object:(id)object
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object userInfo:userInfo];
    });
}
@end
