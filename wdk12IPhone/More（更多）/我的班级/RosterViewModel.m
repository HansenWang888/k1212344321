//
//  RosterViewModel.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "RosterViewModel.h"
#import "WDHTTPManager.h"
#import "ClassModel.h"
#import "StudentModel.h"

@implementation RosterViewModel

- (void)fetchPublicRosterWithModel:(ClassModel *)classModel {
    NSMutableArray *arrayM = [NSMutableArray array];
    [SVProgressHUD show];
    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"bjID" : classModel.id} urlString:[NSString stringWithFormat:@"%@/dl!getHMC.action",EDU_BASE_URL] finished:^(NSDictionary *dict) {
        [SVProgressHUD dismiss];
        NSArray *bjList = dict[@"bjList"];
        NSDictionary *dic = bjList.firstObject;
        NSArray *xsList = dic[@"xsList"];
        classModel.man = 0;
        classModel.woman = 0;
        for (NSDictionary *di in xsList) {
            StudentModel *model = [StudentModel new];
            model.iconImage = di[@"tx"];
            model.name = di[@"xsxm"];
            if ([di[@"xb"] isEqualToString:NSLocalizedString(@"男", nil)]) {
                classModel.man++;
            } else if ([di[@"xb"] isEqualToString:NSLocalizedString(@"女", nil)]) {
                classModel.woman++;
            }
            [arrayM addObject:model];
        }
        classModel.count = xsList.count;
        self.returnBlock(arrayM.copy);
    }];
}

+ (void)exitClassActionJsjs:(NSString *)jsjs bjId:(NSString *)bjId km:(NSString *)km handler:(void(^)(BOOL isSuccess))handler {
    NSString *urlString = [NSString stringWithFormat:@"%@/gd!quitBJ.action",EDU_BASE_URL];
    NSDictionary *parameter = @{@"jsID" : [WDTeacher sharedUser].teacherID,
                                @"xxID" : [WDTeacher sharedUser].schoolID,
                                @"jsjs" : jsjs,
                                @"bjID" : bjId,
                                @"km" : km};
    
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:parameter urlString:urlString finished:^(NSDictionary *data) {
        if ([data[@"isSuccess"] isEqualToString:@"true"]) {
            handler(true);
        } else {
            handler(false);
        }
    }];
}

@end
