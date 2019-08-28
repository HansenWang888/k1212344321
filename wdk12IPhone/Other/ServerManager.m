//
//  ServerManager.m
//  wdk12IPhone
//
//  Created by 官强 on 17/2/24.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "ServerManager.h"

#ifdef DEBUG
#define IDEDTIFIER 1
#else
#define IDEDTIFIER 2
#endif
#define SALFSTR(string) ((string) == nil ? @"" : (string))

@interface ServerManager ()

@property (nonatomic, strong) NSDictionary *dictionary;

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, assign) BOOL isLocation;
@property (nonatomic, strong) NSArray *codeArr;

@end

@implementation ServerManager

+(instancetype)sharedManager{
    
    static ServerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDictionary];
    }
    return self;
}

- (void)initDictionary {
    
    switch (IDEDTIFIER) {
        case 0://阿里演示
        {
            self.dictionary = @{
                                @"USBU":@"https://wdusr.wdcloud.cc",//统一用户
                                @"USKU":@"http://wdktlx.12study.cn/k12/api_ktlx/",//课堂练习
                                @"UBU":@"https://wdusr.wdcloud.cc" ,
                                @"EBU":@"http://wdmobile.12study.cn/jyx-mobile/mobile",//教育学
                                @"FSUU": @"http://wddownload.12study.cn/ptwjfw/rest/fileWS/upload",//文件上传
                                @"FSDU":@"http://wddownload.12study.cn",//文件下载
                                @"IM":@"http://wdim.12study.cn/imserver",//即时通讯
                                @"MS":@"",//日志上传地址
                                @"version":@"阿里演示: 1.2.8"
                                };
            self.appID = @"";
            self.isLocation = NO;
        }
            break;

        case 1:
        {//测试
            self.dictionary = @{
                                @"USBU":@"https://192.168.6.100",  //第一步登录
                                @"RU":@"http://192.168.6.100/jyx-xtgl/rest/v2/jyxxtgl",//第二步获取location
                                @"SAU":@"http://192.168.6.104:8888"//第三步 获取服务器地址
                                };
            self.appID = @"100001496";
            self.isLocation = YES;
        }
            break;
        case 2:
        {//国内生产环境
            self.dictionary = @{
                                @"USBU":@"https://usr.wdcloud.cc",
                                @"RU":@"http://admin.12study.cn/jyx-xtgl/rest/v2/jyxxtgl",
                                @"SAU":@"http://mconf.12study.cn:8888"
                                };
            self.appID = @"500000109";
            self.isLocation = YES;
        }
            break;
        case 3:
        {//国际版环境
            self.dictionary = @{
                                @"USBU":@"https://enusr.vviton.com" ,
                                @"USKU":@"http://enk12.vviton.com/k12/api_ktlx/" ,
                                @"UBU":@"https://enusr.vviton.com" ,
                                @"EBU":@"http://enk12.vviton.com/jyx-mobile/mobile" ,
                                @"FSUU":@"http://ul.wdcloud.cc/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://dl.wdcloud.cc/",
                                @"IM":@"http://enim.vviton.com:81/imserver",
                                @"MS":@"",//日志上传地址
                                @"version":@"1.0.1.9"
                                };
            self.appID = @"";
            self.isLocation = NO;
        }
            break;
        case 4:
        {//法国环境
            self.dictionary = @{
                                @"USBU":@"https://enusr.learningischanging.com" ,
                                @"USKU":@"http://enk12.learningischanging.com/k12/api_ktlx/" ,
                                @"UBU":@"http://enk12.learningischanging.com" ,
                                @"EBU":@"http://enk12.learningischanging.com/jyx-mobile/mobile" ,
                                @"FSUU": @"http://enupload.learningischanging.com/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://endownload.learningischanging.com/",
                                @"IM":@"http://enim.learningischanging.com:81/imserver",
                                @"MS":@"",//日志上传地址
                                @"version":@"1.0.0"
                                };
            self.appID = @"";
            self.isLocation = NO;
        }
            break;
        default:
            break;
    }
}

+ (BOOL)setServerAddressWith:(NSDictionary *)dict {

    //功能模块数组
    NSArray *temArray = dict[@"functionList"];
    
    NSMutableArray *mulArr = @[].mutableCopy;
    for (NSDictionary *item in temArray) {
        NSString *code = item[@"code"];
        NSString *state = item[@"state"];
        if ([state isEqualToString:@"1"]) {
            [mulArr addObject:code];
        }
    }
    
    [ServerManager sharedManager].codeArr = mulArr;
    
    //服务器地址字典
    NSString *jsonString = dict[@"serverAdds"];
    if (!jsonString || !jsonString.length) {
        return NO;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *addDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSString *KTLX_SERVER   = [self getServerString:addDict[@"KTLX_SERVER"] isDelete:NO];
    
    NSString *USBU = addDict[@"AUTHORIZE"][@"addr"];  //统一用户
    NSString *USKU = [KTLX_SERVER stringByAppendingString:@"api_ktlx/"];//课堂练习
    NSString *EBU  = [self getServerString:addDict[@"BUSINESS"] isDelete:YES];       //教育学
    NSString *FSUU = [self getServerString:addDict[@"UPLOAD_FILE"] isDelete:YES];   //文件上传
    NSString *FSDU = [self getServerString:addDict[@"DOWNLOAD_FILE"] isDelete:NO]; //文件下载
    NSString *IM   = [self getServerString:addDict[@"IM_SERVER"] isDelete:YES];     //即时通讯
    NSString *SAU  = addDict[@"ADDRESS_SERVER"][@"addr"];                      //获取区域代码
    NSString *RU   = [self getServerString:addDict[@"REGION"] isDelete:YES];         //获取服务器地址
    NSString *MS   = [self getServerString:addDict[@"MOBILE_SERVER"] isDelete:NO];         //日志上传地址
    [WDLogManager shareManager].logURL = MS;
    NSDictionary *temDict = @{
                              @"USBU": SALFSTR(USBU), //统一用户
                              @"USKU": SALFSTR(USKU), //课堂练习
                              @"EBU":  SALFSTR(EBU),  //教育学
                              @"FSUU": SALFSTR(FSUU), //文件上传
                              @"FSDU": SALFSTR(FSDU), //文件下载
                              @"IM":   SALFSTR(IM),   //即时通讯
                              @"RU":   SALFSTR(RU),   //获取区域代码
                              @"SAU":  SALFSTR(SAU),  //获取服务器地址
                              @"MS":   SALFSTR(MS),   //日志上传地址
                              @"version":@""
                              };
    [ServerManager sharedManager].dictionary = temDict;
    if (!USBU.length || !USKU.length || !EBU.length || !FSUU.length || !FSDU.length ||!IM.length || !RU.length || !SAU.length || !MS.length) {
        return NO;
    }else {
        return YES;
    }
}

- (NSString *)USBU {
    return [[ServerManager sharedManager].dictionary objectForKey:@"USBU"];
}

- (NSString *)USKU {
    return [[ServerManager sharedManager].dictionary objectForKey:@"USKU"];
}

- (NSString *)EBU {
    return [[ServerManager sharedManager].dictionary objectForKey:@"EBU"];
}

- (NSString *)FSUU {
    return [[ServerManager sharedManager].dictionary objectForKey:@"FSUU"];
}

- (NSString *)FSDU {
    return [[ServerManager sharedManager].dictionary objectForKey:@"FSDU"];
}

- (NSString *)IM {
    return [[ServerManager sharedManager].dictionary objectForKey:@"IM"];
}

- (NSString *)RU {
    return [[ServerManager sharedManager].dictionary objectForKey:@"RU"];
}

- (NSString *)SAU {
    return [[ServerManager sharedManager].dictionary objectForKey:@"SAU"];
}

- (NSString *)MS {
    return [[ServerManager sharedManager].dictionary objectForKey:@"MS"];
}
- (NSString *)versionDescription {
    return [[ServerManager sharedManager].dictionary objectForKey:@"version"];
}

+ (NSString *)getServerString:(NSDictionary *)dic isDelete:(BOOL)isDelete{

    if (!dic) {
        return @"";
    }
    
    NSString *addr = dic[@"addr"];
    NSString *path = dic[@"path"];

    if (path && path.length) {
        if (isDelete) {
            path = [path substringToIndex:path.length-1];
        }
    }else {
        if (isDelete) {
            addr = [addr substringToIndex:addr.length-1];
        }
    }
    return [SALFSTR(addr) stringByAppendingString:SALFSTR(path)];
}


@end
