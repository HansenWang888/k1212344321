//
//  HWTaskListRequest.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTaskListRequest.h"
#import "WDHTTPManager.h"
#import "HWSubject.h"
#import "StudentModel.h"

@implementation HWTaskListRequest

+ (void)fetchPublicTeacherSubject:(void(^)(NSArray *data))handler {
    NSString *ID = [WDTeacher sharedUser].teacherID;
    
    NSString *url = [NSString stringWithFormat:@"%@/zy!%@.action",EDU_BASE_URL, @"geJSKM"];

    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"jsID" : ID} urlString:url finished:^(NSDictionary *dict) {
        if (dict) {
            NSMutableArray *arrayM = [NSMutableArray array];
            NSMutableArray *M = [NSMutableArray array];
            
            NSArray *subs = dict[@"kmList"];
            [M addObject:@{@"kmID" : @"all"}];
            [M addObjectsFromArray:subs];
            
            for (NSDictionary *dict in M) {
                [arrayM addObject:[HWSubject subjectWithDict:dict]];
            }
            [arrayM addObject:[HWSubject subjectWithDict:@{@"kmID":@"other"}]];
            
            handler(arrayM);
            return ;
        }
        handler(nil);
    }];
}


+ (void)fetchPublicDataSourceWith:(NSString *)zyID fbdxID:(NSString *)fbdxID fbdxlx:(NSString *)fbdxlx type:(NSInteger)type handler:(void(^)(NSArray *data))handler  {
    NSString *url = [NSString stringWithFormat:@"%@/zyv1!getZYTKZT.action", EDU_BASE_URL];
    
    NSString *zyly = type == 1 ? @"1" : @"0";
    NSDictionary *parameter = @{@"zyID" : zyID,
                                @"zyly" : zyly,
                                @"fbdxID" : fbdxID,
                                @"fbdxlx" :fbdxlx};
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:url finished:^(NSDictionary *dict) {
        
        NSArray *array = dict[@"zytjxx"];
        NSMutableArray *notSubmit = [NSMutableArray array];   // 未提交
        NSMutableArray *yetSubmit = [NSMutableArray array];   // 已提交
        NSMutableArray *yetFeedback = [NSMutableArray array]; // 已反馈
        
        for (NSDictionary *item in array) {
            StudentModel *model = [StudentModel new];
            model.id = item[@"xsID"];
            model.name = item[@"xsxm"];
            model.iconImage = item[@"xstx"];
            if ([model.iconImage isKindOfClass:[NSNull class]]) {
                model.iconImage = @"";
            }
            
            if ([item[@"zt"] isEqualToString:@"0"]) { // 未提交
                [notSubmit addObject:model];
            } else if ([item[@"zt"] isEqualToString:@"1"]) { // 已提交
                [yetSubmit addObject:model];
            } else { // 已反馈
                [yetFeedback addObject:model];
            }
        }
        handler(@[yetSubmit, yetFeedback, notSubmit]);
    }];
}

@end
