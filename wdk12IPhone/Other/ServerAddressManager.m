//
//  ServerAddressManager.m
//  wdk12IPhone
//
//  Created by 官强 on 17/1/13.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "ServerAddressManager.h"

#define IDEDTIFIER 2

@interface ServerAddressManager ()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation ServerAddressManager

+(instancetype)shareInstance{
    
    static ServerAddressManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerAddressManager alloc] init];
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
                                @"version":@"阿里演示: 1.2.8"
                                };
        
        }
            break;
        case 1:
        {//公网临时
            self.dictionary = @{
                                @"USBU":@"https://60.195.40.6",
                                @"USKU":@"",
                                @"UBU":@"http://60.195.40.6" ,
                                @"EBU":@"http://60.195.40.6/jyx-mobile/mobile" ,
                                @"FSUU": @"http://60.195.40.6/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://60.195.40.6",
                                @"IM":@"http://60.195.40.6/imserver",
                                @"version":@""
                                };
            
        }
            break;
        case 2:
        {//测试
            self.dictionary = @{
                                @"USBU":@"https://192.168.6.100" ,
                                @"USKU":@"http://yftest.ktlx.wdcloud.cc/k12/api_ktlx/",
                                @"UBU":@"https://192.168.6.100" ,
                                @"EBU":@"http://192.168.6.125:9040/jyx-mobile/mobile" ,
                                @"FSUU": @"http://192.168.6.100/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://192.168.6.100:8082",
                                @"IM":@"http://192.168.6.104:8080/imserver",
                                @"version":@"测试版本:1.0.1.8"
                                };
        }
            break;
        case 3:
        {//生产
            //国内环境
            self.dictionary = @{
                                @"USBU":@"https://login.qdeduyun.cn",//统一用户
                                @"USKU":@"http://jskj.qdeduyun.cn:2048/k12/api_ktlx/" ,//课堂练习
                                @"UBU":@"https://login.qdeduyun.cn" ,
                                @"EBU":@"http://mobile.qdeduyun.cn/jyx-mobile/mobile" ,//教育学
                                @"FSUU": @"http://upload.qdeduyun.cn/ptwjfw/rest/fileWS/upload" ,//文件上传
                                @"FSDU":@"http://download.qdeduyun.cn/",//文件下载
                                @"IM":@"http://im.qdeduyun.cn/imserver",//即时通讯
                                @"version":@"1.3.0"
                                };
        }
            break;
        case 4:
        {//QD_TEST(这是个什么环境)
            self.dictionary = @{
                                @"USBU":@"https://111.202.238.146" ,
                                @"USKU":@"http://yftest.ktlx.wdcloud.cc/k12/api_ktlx/",
                                @"UBU":@"https://111.202.238.146" ,
                                @"EBU":@"https://111.202.238.146:9040/jyx-mobile/mobile" ,
                                @"FSUU": @"https://111.202.238.146/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://111.202.238.146/ptwjfw/rest/fileWS/delete?",
                                @"IM":@"http://111.202.238.146:9080/imserver",
                                @"version":@""
                                };
            
        }
            break;
        case 5:
        {//武侯地区
            self.dictionary = @{
                                @"USBU":@"https://usr.wdcloud.cc" ,
                                @"USKU":@"http://mobile-wh.wdcloud.cc/k12/api_ktlx/",
                                @"UBU":@"https://usr.wdcloud.cc" ,
                                @"EBU":@"http://mobile-wh.wdcloud.cc/jyx-mobile/mobile" ,
                                @"FSUU": @"http://upload-wh.wdcloud.cc/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://dl.wdcloud.cc/",
                                @"IM":@"http://im.12study.cn/imserver",
                                @"version":@""
                                };
        }
            break;
        case 6:
            self.dictionary = @{//国际版环境
                                @"USBU":@"https://enusr.vviton.com" ,
                                @"USKU":@"http://enk12.vviton.com/k12/api_ktlx/" ,
                                @"UBU":@"https://enusr.vviton.com" ,
                                @"EBU":@"http://enk12.vviton.com/jyx-mobile/mobile" ,
                                @"FSUU": @"http://ul.wdcloud.cc/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://dl.wdcloud.cc/",
                                @"IM":@"http://enim.vviton.com:81/imserver",
                                @"version":@"1.0.1.9"
                                };
            break;
        case 7:
        {//法国生产环境
            self.dictionary = @{
                                @"USBU":@"https://enusr.learningischanging.com" ,
                                @"USKU":@"http://enk12.learningischanging.com/k12/api_ktlx/" ,
                                @"UBU":@"http://enk12.learningischanging.com" ,
                                @"EBU":@"http://enk12.learningischanging.com/jyx-mobile/mobile" ,
                                @"FSUU": @"http://enupload.learningischanging.com/ptwjfw/rest/fileWS/upload" ,
                                @"FSDU":@"http://endownload.learningischanging.com/",
                                @"IM":@"http://enim.learningischanging.com:81/imserver",
                                @"version":@"1.0.0"
                                };
        }
            break;

        default:
            break;
    }
    
}

- (NSString *)USBU {
    return [self.dictionary objectForKey:@"USBU"];
}

- (NSString *)USKU {
    return [self.dictionary objectForKey:@"USKU"];
}

- (NSString *)UBU {
    return [self.dictionary objectForKey:@"UBU"];
}

- (NSString *)EBU {
    return [self.dictionary objectForKey:@"EBU"];
}

- (NSString *)FSUU {
    return [self.dictionary objectForKey:@"FSUU"];
}

- (NSString *)FSDU {
    return [self.dictionary objectForKey:@"FSDU"];
}

- (NSString *)IM {
    return [self.dictionary objectForKey:@"IM"];
}

- (NSString *)versionDescription {
    return [self.dictionary objectForKey:@"version"];
}


@end
