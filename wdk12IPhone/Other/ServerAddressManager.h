//
//  ServerAddressManager.h
//  wdk12IPhone
//
//  Created by 官强 on 17/1/13.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define UNIFIED_USER_BASE_URL   [[ServerAddressManager shareInstance] USBU] //统一用户
//#define UNIFIED_USER_KTLX_URL   [[ServerAddressManager shareInstance] USKU] //课堂练习
//#define USER_BASE_URL           [[ServerAddressManager shareInstance] UBU]
//#define EDU_BASE_URL            [[ServerAddressManager shareInstance] EBU]  //教育学
//#define FILE_SEVER_UNPLOAD_URL  [[ServerAddressManager shareInstance] FSUU] //文件上传
//#define FILE_SEVER_DOWNLOAD_URL [[ServerAddressManager shareInstance] FSDU] //文件下载
//#define IM_URL                  [[ServerAddressManager shareInstance] IM]   //即时通讯
//#define VERSION_DESCRIPTION [[ServerAddressManager shareInstance] versionDescription]

@interface ServerAddressManager : NSObject

+(instancetype)shareInstance;

- (NSString *)USBU;
- (NSString *)USKU;
- (NSString *)UBU;
- (NSString *)EBU;
- (NSString *)FSUU;
- (NSString *)FSDU;
- (NSString *)IM;
- (NSString *)versionDescription;

@end
