//
//  WDDNSAnalysis.m
//  wdk12pad
//
//  Created by 老船长 on 16/7/11.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "WDDNSAnalysis.h"
#include <netdb.h>
#include <arpa/inet.h>

@implementation WDDNSAnalysis
NSString* getIPAddressByHostName(NSString* strHostName)
{
    const char* szname = [strHostName UTF8String];
    struct hostent* phot ;
    @try
    {
        phot = gethostbyname(szname);
    }
    @catch (NSException * e)
    {
        return nil;
    }
    if(phot == NULL) {
        return nil;
    }
    struct in_addr ip_addr;
    memcpy(&ip_addr,phot->h_addr_list[0],4);///h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡
    
    char ip[20] = {0};
    
    inet_ntop(AF_INET,0,0,0);
    
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}
@end
