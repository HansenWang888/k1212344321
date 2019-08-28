//
//  MGPSession.m
//  MobileGateWay
//
//  Created by macapp on 17/3/17.
//  Copyright © 2017年 macapp. All rights reserved.
//

#import "MGPSession.h"

@implementation MGPSession {
    NSURLSession* _session;
    NSString*     _host;
}
+(instancetype)shareInstance{
    static MGPSession* g_mgpsession;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_mgpsession = [[MGPSession alloc] init];
    });
    return g_mgpsession;
}
-(instancetype)init{
    self = [super init];
    _session = [NSURLSession sharedSession];
    _host = @"http://192.168.6.104";
    
    return self;
}
-(void)execute:(id)inparam URL:(NSString*)url Result:(void(^)(NSError *error,id obj))resultBlock{
    NSDictionary* dic = [inparam serializeToJsonValue];
    url = [_host stringByAppendingPathComponent:url];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    
    NSURLSessionDataTask* task = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpRsp = response;
        if(httpRsp.statusCode == 200){
            NSString* rspstr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSError* jerr = nil;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jerr];
            if(jerr){
                if(resultBlock){
                    resultBlock(jerr,nil);
                }
            }
            else{
                if(resultBlock){
                    resultBlock(nil,dic);
                }
            }
            
        } else {
            resultBlock(error,nil);
        }
    }];
    [task resume];

}
-(void)execute:(id)inparam URL:(NSString*)url{
    NSDictionary* dic = [inparam serializeToJsonValue];
    url = [_host stringByAppendingPathComponent:url];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    
    NSURLSessionDataTask* task = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpRsp = response;
        if(httpRsp.statusCode == 200){
            NSString* rspstr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"rspstr:%@",rspstr);
        }
    }];
    [task resume];
}
@end
