//
//  HWPreviewRequest.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWPreviewRequest.h"
#import "HWTaskPreviewPractice.h"
#import "HWTaskPreviewModel.h"
#import "HWTaskPreviewData.h"
#import "WDHTTPManager.h"

@implementation HWPreviewRequest

///  获取预习作业数据
+ (void)fetchPublicPreviewTaskDataWith:(NSString *)taskID handler:(void(^)(HWTaskPreviewModel *data))handler {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",EDU_BASE_URL,@"/kc!getKSYXXX.action"];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"ksysID" : taskID} urlString:url finished:^(NSDictionary *dict) {
        if (dict != nil ) {
            
            NSDictionary *data = dict[@"yxxx"];
            
            HWTaskPreviewModel *model = [HWTaskPreviewModel new];
            model.lxList = [NSMutableArray array];
            model.zlList = [NSMutableArray array];
            
            NSArray *array = data[@"zlList"];
            for (NSDictionary *item in array) {
                HWTaskPreviewData *da = [HWTaskPreviewData new];
                da.zlID = item[@"zlID"];
                da.fywID = item[@"fywID"];
                da.wjgs = item[@"wjgs"];
                da.zlmc = item[@"zlmc"];
                da.zldz = item[@"zldz"];
                da.zldznew = item[@"zldznew"];
                da.pjts = item[@"pjts"];
                da.zts = item[@"zts"];
                [model.zlList addObject:da];
            }
            
            NSArray *lxList = data[@"lxList"];
            for (NSDictionary *item in lxList) {
                HWTaskPreviewPractice *pr = [HWTaskPreviewPractice new];
                pr.xqID = item[@"xqID"];
                pr.lx = item[@"lx"];
                pr.lxbm = item[@"lxbm"];
                [model.lxList addObject:pr];
            }
            handler(model);
            return ;
        } else {
            handler(nil);
        }
    }];
}

@end
