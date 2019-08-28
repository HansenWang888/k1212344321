//
//  WDHTTPManager.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/18.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDHTTPManager.h"
#import "MediaOBJ.h"

@interface WDHTTPManager()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) AFHTTPSessionManager *manager;
//  码表地扯 http://wd.12study.cn/jyx-mobile/mobile/dl!getMB.action?&sjbb=000001
@end

@implementation WDHTTPManager

+ (instancetype)sharedHTTPManeger{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return  instance;
}

- (NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 15.0;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}

- (AFHTTPSessionManager *)manager {

    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",nil];
        _manager.requestSerializer.timeoutInterval = 15;
        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    return _manager;
}

/*******************************G-E-T****************************************/
// TODO: -
- (void)getMethodDataWithParameter:(NSDictionary *)prameter urlString:(NSString *)urlString finished:(void (^)(NSDictionary *))finished {
    
    
    NSMutableString *str = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@?", urlString]];
    [prameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [str appendString:[NSString stringWithFormat:@"%@=%@&", key, obj]];
    }];
    if (prameter.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    }
    WDULog(@"%@", str);
    [self.manager GET:urlString parameters:prameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject) {
                finished(responseObject);
                return ;
        }
        finished(nil);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        WDULog(@"%@",error);
        finished(nil);
    }];
}

/*******************************P-O-S-T****************************************/
- (void)postMethodDataWithParameter:(NSDictionary *)prameter urlString:(NSString *)urlString finished:(void (^)(NSDictionary *))finished {
    
    
    NSMutableString *str = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@?", urlString]];
    [prameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [str appendString:[NSString stringWithFormat:@"%@=%@&", key, obj]];
    }];
    if (prameter.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    }
    WDULog(@"%@",str);
    [self.manager POST:urlString parameters:prameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject) {
                finished(responseObject);
            return;
        }
        finished(nil);
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"上传失败", nil)];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络异常", nil)];
        WDULog(@"%@",error);
        finished(nil);
    }];
}

-(void)uploadWithPicture:(NSArray *)pictures finished:(void (^)(NSDictionary *))finished {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"上传附件中...", nil)];
    NSString *url = [NSString stringWithFormat:@"%@",FILE_SEVER_UNPLOAD_URL];

    [self.manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        int i ;
        for (UIImage *img in pictures) {
            NSData *data = UIImageJPEGRepresentation(img, 0.5);//压缩图片
            [formData appendPartWithFileData:data name:@"files" fileName:[NSString stringWithFormat:@"picture%d.png",i] mimeType:@"application/octect-stream"];
            i++;
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"成功%@",responseObject);
        NSArray *array = responseObject[@"msgObj"];
        if (responseObject[@"successFlg"] && array.count > 0) {
            finished(responseObject);
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"上传附件成功", nil)];
            return ;
        }
        finished(nil);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        WDULog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"上传附件失败", nil)];
        finished(nil);
    }];
}

- (void)uploadWithAdjunctFileWithData:(NSArray<MediaOBJ *> *)array progressBlock:(void (^)(double))progressBlock finished:(void(^)(NSDictionary *))finished {
    NSString *url = [NSString stringWithFormat:@"%@",FILE_SEVER_UNPLOAD_URL];
    
    [self.manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (MediaOBJ *media in array) {
            [formData appendPartWithFileData:media.mediaData name:@"files" fileName:[NSString stringWithFormat:@"file%d.%@",arc4random() % 100000,media.mediaType] mimeType:@"application/octect-stream"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(uploadProgress.fractionCompleted);
            }
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSArray *array = responseObject[@"msgObj"];
        if (responseObject[@"successFlg"] && array.count > 0) {
            finished(responseObject);
            return ;
        }
        finished(nil);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        WDULog(@"上传附件失败%@",error);
        finished(nil);
    }];
}

- (void)loadMyCourseListWithID:(NSString *)ID date:(NSString *)date paramKey:(NSString *)key method:(NSString *)method finished:(void (^)(NSDictionary *))finished {
    
    NSString *str = [NSString stringWithFormat:@"%@/kb!%@.action",EDU_BASE_URL,method];
    NSDictionary *dict = @{@"rq" : date, key : ID};
    
    WDULog(@"%@?%@=%@&%@=%@", str, @"rq", date, key, ID);
    [self.manager GET:str parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject == nil) {
            finished(nil);
            return ;
        }
        finished(responseObject);
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        WDULog(@"%@",error);
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络异常", nil)];
        finished(nil);
    }];
}

- (void)loginIDWithUserInfo:(NSString *)loginID userType:(NSString *)userType finished:(void (^)(NSDictionary *))finish{
    
    
    NSString *methodStr = @"";
    NSArray * types = [userType componentsSeparatedByString:@","];
    for (NSString * type in types) {
        if ([type isEqualToString:@"01"]) {
            methodStr = @"getJSXX";
        }
    }
    
    if (![methodStr isEqualToString:@"getJSXX"]) {
        finish(nil);
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/dl!%@.action",EDU_BASE_URL,methodStr];
    NSDictionary *dict = @{@"loginID" : loginID};
    
    WDULog(@"%@?loginID=%@", url, loginID);
    [self.manager GET:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject == nil) {
            finish(nil);
            return;
        }
            finish(responseObject);
//        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        WDULog(@"%@",error);
        finish(nil);
    }];
}

- (void)verifyLoginWithAccount:(NSString *)account password:(NSString *)password finished:(void (^)(NSDictionary *))finished{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ptyhzx-uic/rest/v1/users/check/account_passwd_return_loginid",UNIFIED_USER_BASE_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray *strs = [version componentsSeparatedByString:@"."];
    if (strs.count == 4) {
        version = [NSString stringWithFormat:@"%@.%@.%@",strs[0],strs[1],strs[2]];
    }
    NSString *str = [NSString stringWithFormat:@"account=%@&password=%@&yyxtdm=103&yddbbh=%@",account,password,version];

    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    WDULog(@"%@?%@", url, str);
    
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                finished(nil);
//                WDULog(@"%@",error);
            }else{
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    finished(dict);
//                NSLog(@"%@---%@",dict,response);
            }
        });
    }] resume];
}

- (void)postHTTPSWithParameterDict:(NSDictionary *)dict urlString:(NSString *)urlString contentType:(NSString *)contentType finished:(void (^)(NSDictionary *))finished  {
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    request.HTTPBody = data;
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSString *str = [self parameter:dict url:urlString];
    WDULog(@"%@", str);
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                finished(nil);
                WDULog(@"%@",error);
            }else{
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    finished(dict);
            }
        });
    }] resume];
}

- (NSString *)parameter:(NSDictionary *)dict url:(NSString *)url {
    NSMutableString *str = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@?", url]];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [str appendString:[NSString stringWithFormat:@"%@=%@&", key, obj]];
    }];
    if (dict.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    }
    return str;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    
    // 判断是否是信任服务器证书，HTTPS的访问基本上都是信任证书
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        // 使用受保护空间中的服务器信任创建凭据
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        // 通过 completionHandler 告诉服务器信任证书
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

@end
