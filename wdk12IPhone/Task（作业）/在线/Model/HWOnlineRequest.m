//
//  HWOnlineRequest.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/15.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWOnlineRequest.h"
#import "HWOnlineTaskModel.h"
#import "HWQuestionPaper.h"
#import "WDHTTPManager.h"
#import "HWTaskModel.h"

@implementation HWOnlineRequest

+ (void)fetchOnlineTaskPatternContent:(NSString *)taskId handler:(void(^)(HWOnlineTaskModel *model))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zy!getZXZY.action"];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"zyID" : taskId} urlString:url finished:^(NSDictionary *dict) {
        if (dict != nil ) {
            HWOnlineTaskModel *model = [HWOnlineTaskModel new];
            NSDictionary *item = dict[@"zxzyxq"];
            model.sjList = [NSMutableArray array];
            model.stList = [NSMutableArray array];
            
            NSArray *sjList = item[@"sjList"];
            for (NSDictionary *item in sjList) {
                HWQuestionPaper *qp = [HWQuestionPaper new];
                qp.sjID = item[@"sjID"];
                qp.sjMC = item[@"sjmc"];
                [model.sjList addObject:qp];
            }            
            model.stList = item[@"stList"];
            handler(model);
            return ;
        }
        handler(nil);
    }];
}

+ (void)fetchPublicOnlineTaskQuestionPaperDataWith:(NSString *)sjID handler:(void(^)(NSArray *data))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!getZXZYSJ.action"];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"sjID" : sjID} urlString:url finished:^(NSDictionary *dict) {
        if (dict != nil ) {
            
            NSDictionary *data = dict[@"sjxq"];
            handler(data[@"stList"]);
            return ;
        } else {
            handler(nil);
        }
    }];
}

+ (void)fetchStudentAnswerContentWith:(NSString *)zyId xsId:(NSString *)xsId fbdxId:(NSString *)fbdxId sjId:(NSString *)sjId handler:(void(^)(NSDictionary *dict))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!getXSZXZYFK.action"];
    NSDictionary *parameter = @{@"zyID" : zyId,
                                @"xsID" : xsId,
                                @"fbdxID" : fbdxId,
                                @"sjID" : sjId};
    
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
        if (dict != nil ) {
            handler([dict[@"zytjxx"] firstObject]);
            return ;
        } else {
            handler(nil);
        }
    }];
}

///  获取在线作业数据
+ (void)getOnlineTaskDataWith:(NSString *)taskID handler:(void(^)(NSArray *data))handler {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zy!getZXZY.action"];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"zyID" : taskID} urlString:url finished:^(NSDictionary *dict) {
        
        if (dict != nil ) {
            NSArray *sjList = dict[@"sjList"];
            __block int i = 0;
            NSMutableArray *arrayM = [NSMutableArray array];
            [arrayM addObjectsFromArray:dict[@"stList"]];
            for (NSDictionary *item in sjList) {
                [HWOnlineRequest fetchPublicOnlineTaskQuestionPaperDataWith1:item[@"sjID"] handler:^(NSArray *data) {
                    i++;
                    [arrayM addObjectsFromArray:data];
                    if (i == sjList.count) {
                        handler(arrayM);
                    }
                }];
            }
            
            if (sjList.count == 0) {
                handler(arrayM);
            }
            return ;
        }
        handler(nil);
    }];
}

+ (void)fetchPublicOnlineTaskQuestionPaperDataWith1:(NSString *)sjID handler:(void(^)(NSArray *data))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!getZXZYSJ.action"];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"sjID" : sjID} urlString:url finished:^(NSDictionary *dict) {
        if (dict != nil ) {
            NSDictionary *data = dict[@"sjxq"];
            NSArray *array = data[@"stList"];
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *item in array) {
                NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:item];
                dictM[@"sjID"] = sjID;
                [arrayM addObject:dictM];
            }
            
            handler(arrayM.copy);
            return ;
        }
    }];
}


+ (void)fetchOnlineTaskFeedbackWith:(NSString *)zyId sjId:(NSString *)sjId fbdxlx:(NSString *)fbdxlx fbdxId:(NSString *)fbdxId handler:(void(^)(NSArray *da))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!getJSZXZYFK.action"];
    
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"sjID" : sjId ? sjId : @"", @"zyID" : zyId, @"fbdxlx" : fbdxlx, @"fbdxID" : fbdxId} urlString:url finished:^(NSDictionary *dict) {
        if (dict != nil ) {
            handler(dict[@"zytjxx"]);
            return ;
        }
    }];
}

+ (void)onlineTaskScoreWith:(NSString *)xsId fbdxId:(NSString *)fbdxId zyId:(NSString *)zyId sjId:(NSString *)sjId stId:(NSString *)stId xtId:(NSString *)xtId stpf:(NSString *)stpf handler:(void(^)(BOOL isSuccess))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!tjstpf.action"];
    NSDictionary *parameter = @{@"jsID" : [WDTeacher sharedUser].teacherID,
                                @"xsID" : xsId,
                                @"fbdxID" : fbdxId,
                                @"zyID" : zyId,
                                @"sjID" : !sjId?@"":sjId,
                                @"stID" : stId,
                                @"xtID" : xtId,
                                @"stpf" : stpf};
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
        if (dict) {
            BOOL isSuccess = dict[@"isSuccess"];
            if (isSuccess) {
                handler(true);
            } else {
                handler(false);
                return ;
            }
        } else {
            handler(false);
        }
    }];
}

///  在线作业客观题批改
+ (void)onlineTaskObjectiveScoreWith:(NSString *)zyId fbdxId:(NSString *)fbdxId xsId:(NSString *)xsId handler:(void(^)(BOOL isSuccess))handler {
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/zyv1!tjstpfList.action"];
    
    NSDictionary *parameter = @{@"zyID" : zyId,
                                @"fbdxID" : fbdxId,
                                @"jsID" : [WDTeacher sharedUser].teacherID,
                                @"xsID" : xsId,
                                @"stpfList" : @""};
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
        if (dict) {
            BOOL isSuccess = dict[@"isSuccess"];
            if (isSuccess) {
                handler(true);
            } else {
                handler(false);
                return ;
            }
        } else {
            handler(false);
        }
    }];
}

@end
