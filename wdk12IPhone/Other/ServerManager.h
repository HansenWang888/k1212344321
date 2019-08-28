//
//  ServerManager.h
//  wdk12IPhone
//
//  Created by 官强 on 17/2/24.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>


#define UNIFIED_USER_BASE_URL   [[ServerManager sharedManager] USBU] //统一用户
#define UNIFIED_USER_KTLX_URL   [[ServerManager sharedManager] USKU] //课堂练习
#define EDU_BASE_URL            [[ServerManager sharedManager] EBU]  //教育学
#define FILE_SEVER_UNPLOAD_URL  [[ServerManager sharedManager] FSUU] //文件上传
#define FILE_SEVER_DOWNLOAD_URL [[ServerManager sharedManager] FSDU] //文件下载
#define IM_URL                  [[ServerManager sharedManager] IM]   //即时通讯

#define VERSION_DESCRIPTION [[ServerManager sharedManager] versionDescription]

#define SERVER_ADDRESS_URL      [[ServerManager sharedManager] SAU]  //获取服务器地址
#define REGION_URL              [[ServerManager sharedManager] RU]  //获取区域代码

#define MOBILE_SERVER_URL       [[ServerManager sharedManager] MS]  //日志上传地址

#define Server_AppID  [ServerManager sharedManager].appID  //从服务器注册的 appID

#define Location  [ServerManager sharedManager].isLocation //是否走location


#define User_Location_Key @"User_LocationKey" //存储 location 的键(包含用户id)
#define User_Server_Address_Key @"User_ServerAddressKey" //存储 服务器地址 的键
#define Location_Key @"Location_Key" // location 的键

@interface ServerManager : NSObject

@property (nonatomic, strong, readonly) NSString *appID;
@property (nonatomic, assign, readonly) BOOL isLocation;
@property (nonatomic, strong, readonly) NSArray *codeArr;

+ (ServerManager *)sharedManager;

+ (BOOL)setServerAddressWith:(NSDictionary *)dict;

- (NSString *)USBU;
- (NSString *)USKU;
- (NSString *)EBU;
- (NSString *)FSUU;
- (NSString *)FSDU;
- (NSString *)IM;
- (NSString *)RU;
- (NSString *)SAU;
- (NSString *)MS;
- (NSString *)versionDescription;

@end
