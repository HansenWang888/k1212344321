//
//  HWCreatTaskVIewModel.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/6.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWCreatTaskVIewModel.h"
#import "WDHTTPManager.h"
#import "HWSubject.h"

@implementation HWCreatTaskVIewModel

- (void)fetchPublicAllSubjectAction {
    
    NSString *url = [NSString stringWithFormat:@"%@/zy!%@.action",EDU_BASE_URL,@"geJSKM"];
    NSMutableArray *arrayM = [NSMutableArray array];
    
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"jsID" : [WDTeacher sharedUser].teacherID} urlString:url finished:^(NSDictionary *dict) {
        if (dict) {
            NSMutableArray *M = [NSMutableArray array];
            NSArray *subs = dict[@"kmList"];
            [M addObjectsFromArray:subs];
            for (NSDictionary *dict in M) {
                if ([dict[@"kmID"] intValue] > 1000) {
                    break;
                }
                [arrayM addObject:[HWSubject subjectWithDict:dict]];
            }
            HWSubject *lastSub = [HWSubject new];
            lastSub.subjectID = @"";
            lastSub.subjectCH = NSLocalizedString(@"其他", nil);
            [arrayM addObject:lastSub];
            self.returnBlock(arrayM);
            return ;
        }
        self.failureBlock();
    }];
}

@end
