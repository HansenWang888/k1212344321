//
//  DDHttpServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDHttpServer.h"
#import "DDAFClient.h"
@implementation DDHttpServer
- (void)loginWithUserName:(NSString*)userName
                 password:(NSString*)password
                  success:(void(^)(id respone))success
                  failure:(void(^)(id error))failure
{
    //    DDHttpModule* module = [DDHttpModule shareInstance];
    NSMutableDictionary* dictParams = [NSMutableDictionary dictionary];
    [dictParams setObject:userName forKey:@"user_email"];
    [dictParams setObject:password forKey:@"user_pass"];
    [dictParams setObject:@"ooxx" forKey:@"macim"];
    [dictParams setObject:@"1.0" forKey:@"imclient"];
    [dictParams setObject:@"1" forKey:@"remember"];
    [DDAFClient jsonFormPOSTRequest:@"user/zlogin/" param:dictParams success:^(id result) {
        success(result);
    } failure:^(NSError * error) {
        failure(error);
    }];
    
}
-(void)getMsgIp:(void(^)(NSDictionary *dic))block failure:(void(^)(NSString* error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    manager.requestSerializer.timeoutInterval = 5.0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString* imurl = [defaults objectForKey:@"ipaddress"];
    
    [manager GET:[NSString stringWithFormat:@"%@",[defaults objectForKey:@"ipaddress"]] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        block(responseDictionary);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSString *errordes = error.domain;
        NSLog(@"%@   %ld",error.domain,error.code);
        failure(errordes);
    }];
    
//    [manager GET:[NSString stringWithFormat:@"%@",[defaults objectForKey:@"ipaddress"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//       
//        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
// 
//        block(responseDictionary);
//        
//               
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSString *errordes = error.domain;
//        NSLog(@"%@   %ld",error.domain,error.code);
//        failure(errordes);
//
//    } ];
    
    
}
@end