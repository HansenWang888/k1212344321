//
//  HWNotOnlineRequest.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWNotOnlineRequest.h"
#import "HWAccessoryModel.h"
#import "HWNotOnlineModel.h"
#import "WDHTTPManager.h"
#import "HWStudentTask.h"

@implementation HWNotOnlineRequest

+ (void)getNotOnlineTaskDetailWith:(NSString *)taskId handler:(void(^)(HWNotOnlineModel *data))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!getFZXZYXQ.action"];
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:@{@"zyID" : taskId} urlString:url finished:^(NSDictionary *data) {
        
        if (data) {
            HWNotOnlineModel *model = [HWNotOnlineModel new];
            model.zynr = data[@"zynr"];
            model.fjList = [NSMutableArray array];
            
            NSArray *array = data[@"fjList"];
            for (NSDictionary *item in array) {
                HWAccessoryModel *acc = [HWAccessoryModel new];
                acc.fjzmdz = [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL, item[@"fjdznew"] ? item[@"fjdznew"] : item[@"fjzmdz"]];
                acc.fjdz = [NSString stringWithFormat:@"%@/%@",FILE_SEVER_DOWNLOAD_URL, item[@"fjdz"]];
                acc.fjdx = item[@"fjdx"];
                acc.fjmc = item[@"fjmc"];
                acc.fjgs = item[@"fjgs"];
                acc.fjdzNotBaseUrl = item[@"fjdz"];
                if (!acc.fjgs) {
                    acc.fjgs = item[@"fjgs"];
                }
                [model.fjList addObject:acc];
            }
            handler(model);
            return ;
        }
        handler(nil);

    }];
}
//
+ (void)getNotOnlineFeedBackWith:(NSString *)zyId fbdxlx:(NSString *)fbdxlx fbdxId:(NSString *)fbdxId handler:(void(^)(NSArray *data))handler {
    NSString *url = [NSString stringWithFormat:@"%@/zyv1!%@.action", EDU_BASE_URL, @"getFZXZYFK"];
    
    NSDictionary *parameter = @{@"zyID" : zyId,
                                @"fbdxlx" : fbdxlx,
                                @"fbdxID" : fbdxId};
    
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *data) {
        if (data) {
            
            NSArray *zytjxx = data[@"zytjxx"];
            NSMutableArray *arrayM = [NSMutableArray array];
            
            for (NSDictionary *dict in zytjxx) {
                HWStudentTask *model = [HWStudentTask new];
                model.xsID = dict[@"xsID"];
                model.pf   = dict[@"pf"];
                model.py   = dict[@"py"];
                model.zt   = dict[@"zt"];
                model.xsxm = dict[@"xsxm"];
                model.fjList = [NSMutableArray array];
                model.jsfjList = [NSMutableArray array];
                
                NSArray *fjList = dict[@"fjList"];
                for (NSDictionary *item in fjList) {
                    HWAccessoryModel *mo = [HWAccessoryModel new];
                    mo.fjdx = item[@"fjdx"];
                    mo.fjdz = [NSString stringWithFormat:@"%@%@", FILE_SEVER_DOWNLOAD_URL, item[@"fjdz"]];
                    mo.fjzmdz = [NSString stringWithFormat:@"%@%@", FILE_SEVER_DOWNLOAD_URL, item[@"fjdznew"] ? item[@"fjdznew"] : item[@"fjzmdz"]];
                    mo.fjmc = item[@"fjmc"];
                    if (!mo.fjgs) {
                        mo.fjgs = item[@"fjgs"];
                    }
                    [model.fjList addObject:mo];
                }
                
                NSArray *jsfjList = dict[@"jsfjList"];
                for (NSDictionary *item in jsfjList) {
                    HWAccessoryModel *mo = [HWAccessoryModel new];
                    mo.fjdx = item[@"fjdx"];
                    mo.fjdz = [NSString stringWithFormat:@"%@%@", FILE_SEVER_DOWNLOAD_URL, item[@"fjdz"]];
                    mo.fjzmdz = [NSString stringWithFormat:@"%@%@", FILE_SEVER_DOWNLOAD_URL, item[@"fjdznew"] ? item[@"fjdznew"] : item[@"fjzmdz"]];
                    mo.fjmc = item[@"fjmc"];
                    mo.fjgs = item[@"wjgs"];
                    if (!mo.fjgs) {
                        mo.fjgs = item[@"fjgs"];
                    }
                    [model.jsfjList addObject:mo];
                }
                [arrayM addObject:model];
            }
            handler(arrayM.copy);
            return ;
        } else {
            handler(nil);
        }
        
    }];
}

+ (void)submitTaskWith:(NSString *)xsId taskId:(NSString *)taskId zypf:(NSString *)zypf zypy:(NSString *)zypy fjList:(NSArray *)fjList handler:(void(^)(BOOL isSucceess))handler {
    
    NSString *url = [NSString stringWithFormat:@"%@/zyv1!%@.action", EDU_BASE_URL, @"updateFKXX"];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (HWAccessoryModel *item in fjList) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        dictM[@"fjmc"] = item.fjmc;
        
        NSRange rang  =[item.fjdz rangeOfString:FILE_SEVER_DOWNLOAD_URL];
        NSString *str = [item.fjdz substringFromIndex:rang.length];
        
        dictM[@"fjdz"] = str;
        
        dictM[@"fjdx"] = item.fjdx;
        dictM[@"fjgs"] = item.fjgs;
        [arrayM addObject:dictM];
    }
    NSString *fjData = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:arrayM options:0 error:nil] encoding:NSUTF8StringEncoding];

    NSDictionary *parameter = @{@"jsID" : [WDTeacher sharedUser].teacherID,
                                @"xsID" : xsId,
                                @"zyID" : taskId,
                                @"zypf" : zypf,
                                @"zypy" : zypy,
                                @"fjList" : fjData};
    
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {

        if (dict) {
            BOOL isSuccess = dict[@"isSuccess"];
            if (isSuccess) {
                handler(true);
            } else {
                handler(false);
                //                [SVProgressHUD showErrorWithStatus:@"批改失败，请稍候重试"];
                return ;
            }
        } else {
            handler(false);
        }
    }];
}

@end
