//
//  SubjectListRequest.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "SubjectListRequest.h"
#import "WDHTTPManager.h"
#import "HWTaskModel.h"

@implementation SubjectListRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.myts = 20;
        self.zyqs = @"0";
        self.yxqs = @"0";
    }
    return self;
}

- (void)fetchNextPageModels:(void (^)(NSArray *data))handler {
    return [self fetchModels:handler];
}

- (void)fetchFirstPageModels:(void (^)(NSArray *data))handler {
    self.zyqs = @"0";
    self.yxqs = @"0";
    [self fetchModels:handler];
}

- (void)fetchModels:(void (^)(NSArray *data))handler {

    NSString *url = [NSString stringWithFormat:@"%@/zyv1!%@.action",EDU_BASE_URL,@"getJSZYListPhone"];
    if (!self.kmID) {
        self.kmID = @"all";
    }
    NSDictionary *paras = @{@"myts" : @(self.myts),
                            @"zyqs" : self.zyqs ? self.zyqs : @"0",
                            @"yxqs" : self.yxqs,
                            @"jsID" : [WDTeacher sharedUser].teacherID,
                            @"qsts" : @(10),
                            @"kmID" : self.kmID};

    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:paras urlString:url finished:^(NSDictionary *dict) {
        if (dict) {
            self.zyqs = dict[@"zyqs"];
            self.yxqs = dict[@"yxqs"];
            NSArray *zyList = dict[@"zyList"];
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *item in zyList) {
                if (![item[@"kmdm"] isEqualToString:@"all"]) {
                    [arrayM addObject:[HWTaskModel objectWithDict:item]];
                }
            }
            handler(arrayM);
            return ;
        }
        handler(nil);
    }];
}

@end
