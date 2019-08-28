//
//  HWAddClassViewModel.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWAddClassViewModel.h"
//#import "SmallGroupCheckRequest.h"
#import "SmallGroupStudentModel.h"
#import "ClassSmallListModel.h"
#import "WDHTTPManager.h"
#import "StudentModel.h"
#import "ClassModel.h"

@implementation HWAddClassViewModel

- (void)fetchPublicAllClassroomList {
    NSMutableArray *dataM = [NSMutableArray array];
    ///  班主任班级数组
    NSArray *masterList = [WDTeacher sharedUser].masterList;
    NSArray *teacherList = [WDTeacher sharedUser].teacherList;
    
    NSMutableArray *tempA = [NSMutableArray array];
    
    for (NSDictionary *dict in teacherList) {
        NSArray *bjList = dict[@"bjList"];
        for (NSDictionary *dic in bjList) {
            
            if (![tempA containsObject:dic[@"bjID"]]) { // 如果不包含则创建
                ClassModel *item = [ClassModel objectWithDict:dic];
                [dataM addObject:item];
                item.jsjs = dict[@"jsjs"];
                item.kmList = [NSMutableArray array];
                [item.kmList addObject:dict[@"km"]];
                [tempA addObject:dic[@"bjID"]];
            } else { // 如果包含则取出
                ClassModel *model;
                for (ClassModel *item in dataM) {
                    if ([item.id isEqualToString:dic[@"bjID"]]) {
                        model = item;
                    }
                }
                [model.kmList addObject:dict[@"km"]];
            }
        }
    }
    
    for (NSDictionary *dict in masterList) {
        if (![tempA containsObject:dict[@"bjID"]]) {
            ClassModel *model = [ClassModel objectWithDict:dict];
            [dataM addObject:model];
            model.jsjs = dict[@"jsjs"];
            model.kmList = [NSMutableArray array];
            if (dict[@"km"]) {
                [model.kmList addObject:dict[@"km"]];
            }
            [tempA addObject:model.id];
        } else {
            ClassModel *model;
            for (ClassModel *item in dataM) {
                if ([item.id isEqualToString:dict[@"bjID"]]) {
                    model = item;
                }
            }
            if (model && dict[@"km"]) {
                [model.kmList addObject:dict[@"km"]];
            }
        }
    }
    self.returnBlock(dataM);
}

- (void)fetchPublicSmallGroupWtih:(NSString *)classId {
    
    
    NSDictionary *paramter = @{@"bjID" : classId,
                               @"jsID" : [WDTeacher sharedUser].teacherID,
                               @"xxID" : [WDTeacher sharedUser].schoolID};
    [[WDHTTPManager sharedHTTPManeger] postMethodDataWithParameter:paramter urlString:[NSString stringWithFormat:@"%@/bjv1!getBJXZ.action",EDU_BASE_URL] finished:^(NSDictionary *dict) {
        
        if ([dict[@"succflag"] integerValue] == 0) { // 成功
            NSDictionary *da = dict[@"data"];
            ClassSmallListModel *model = [ClassSmallListModel new];
            model.isCurrentTerm = [da[@"sfdqxq"] integerValue] == 0 ? true : false;
            model.smallGroupList = [NSMutableArray array];
            
            NSArray *array = da[@"xzList"];
            for (NSDictionary *item in array) {
                [model.smallGroupList addObject:[SmallGroupStudentModel objectWithDict:item]];
            }
            self.returnBlock(model.smallGroupList);
            return ;
        } else {
            self.failureBlock(nil);
        }
    }];
}

- (void)fetchPublicClassStudentWith:(NSString *)classId {

    [[WDHTTPManager sharedHTTPManeger] getMethodDataWithParameter:@{@"bjID" : classId} urlString:[NSString stringWithFormat:@"%@/dl!getHMC.action",EDU_BASE_URL] finished:^(NSDictionary *dict) {
        if (dict) {
            NSMutableArray *arrayM = [NSMutableArray array];
            NSArray *bjList = dict[@"bjList"];
            NSDictionary *dic = bjList.firstObject;
            NSArray *xsList = dic[@"xsList"];
            for (NSDictionary *di in xsList) {
                StudentModel *st = [StudentModel objectWithDict:di];
                st.classId = classId;
                [arrayM addObject:st];
            }
            self.returnBlock(arrayM);
            return ;
        }
        self.failureBlock(nil);
        return ;
    }];
}

@end
