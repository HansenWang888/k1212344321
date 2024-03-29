//
//  DDAFClient.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-29.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDAFClient.h"
#import "std.h"
#import "NSDictionary+Safe.h"
@implementation DDAFClient
static NSString* const DD_URL_BASE = @"http://www.mogujie.com/";

+(void) handleRequest:(id)result
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure
{
    
    if (![result isKindOfClass:[NSDictionary class]]) {
        NSError * error = [NSError errorWithDomain:@"data formate is invalid" code:-1000 userInfo:nil];
        BLOCK_SAFE_RUN(failure, error);
        return;
    }
   long int code =[[[result safeObjectForKey:@"status"] objectForKey:@"code"] integerValue];
    NSString *msg =[[result safeObjectForKey:@"status"] objectForKey:@"msg"];
    if (1001 == code)
    {
        id object = [result valueForKey:@"result"];
        object = isNull(object) ? result : object;
        BLOCK_SAFE_RUN(success,object);
    }
    else
    {
      
        if (msg)
        {
            NSError* error = [NSError errorWithDomain:msg code:code userInfo:nil];
            failure(error);
        }
        else
        {
            failure(nil);
        }
    }
    
    
}
+(void) jsonFormRequest:(NSString *)url param:(NSDictionary *)param fromBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
            [DDAFClient handleRequest:(NSDictionary *)responseObject success:success failure:failure];
        }else
        {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            [DDAFClient handleRequest:responseDictionary success:success failure:failure];
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        BLOCK_SAFE_RUN(failure,error);

    }];
   
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
//            [DDAFClient handleRequest:(NSDictionary *)responseObject success:success failure:failure];
//        }else
//        {
//            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//            [DDAFClient handleRequest:responseDictionary success:success failure:failure];
//        }
//       
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//       BLOCK_SAFE_RUN(failure,error);
//    }];
    
}
+(void) jsonFormPOSTRequest:(NSString *)url param:(NSDictionary *)param success:(void (^)(id))success failure:(void (^)(NSError *))failure{

//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *fullPath = [NSString stringWithFormat:@"%@%@",DD_URL_BASE,url];

    [manager POST:fullPath parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         WDULog(@"%@<------",string);
        [DDAFClient handleRequest:responseDictionary success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            if([error.domain isEqualToString:NSURLErrorDomain])
              error = [NSError errorWithDomain:IMLocalizedString(@"没有网络连接。", nil) code:-100 userInfo:nil];
            BLOCK_SAFE_RUN(failure,error);
    }];
}

@end
