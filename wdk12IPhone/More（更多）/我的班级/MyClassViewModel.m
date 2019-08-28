//
//  MyClassViewModel.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "MyClassViewModel.h"
#import "WDHTTPManager.h"
#import "ClassModel.h"
#import "HWSubject.h"
#import "WDMB.h"

@implementation MyClassViewModel

- (void)fetchPublicMyClass {
    
    WDTeacher * teacher = [WDTeacher sharedUser];
    
    [[WDHTTPManager sharedHTTPManeger] loginIDWithUserInfo:teacher.loginID userType:[WDUser sharedUser].userType  finished:^(NSDictionary * ruledic) {
        
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        
        NSArray *array = ruledic[@"jsjsxxList"];
        for (NSDictionary *item in array) {
            
            NSArray *bjList = item[@"bjList"];
            for (NSDictionary *it in bjList) {
                ClassModel *model = dictM[it[@"bjID"]];

                if (!model) {
                    model = [ClassModel new];
                    model.subjects = [NSMutableString string];
                    model.kmList = [NSMutableArray array];
                    model.roleCode = [NSMutableSet set];
                }
                model.id = it[@"bjID"];
                
                [model.roleCode addObject:item[@"jsjs"]];
                if (model.roleCode.count == 2) { // 既是班主任又是任课老师
                    model.role = [NSString stringWithFormat:@"%@  %@", NSLocalizedString(@"班主任", nil), NSLocalizedString(@"任课老师", nil)];
                } else {
                    if (model.roleCode.count == 1) {
                        model.role = NSLocalizedString(([[model.roleCode allObjects].firstObject isEqual:@"01"] ? @"班主任" : @"任课老师"), nil);
                    }
                }
                
                model.name = it[@"bjmc"];
                if (WDMB.MBToSubject[item[@"km"]]) {
                    [model.subjects appendFormat:@"%@、",  WDMB.MBToSubject[item[@"km"]]];
                    HWSubject *sub = [HWSubject new];
                    sub.subjectID = item[@"km"];
                    sub.subjectCH = WDMB.MBToSubject[item[@"km"]];
                    [model.kmList addObject:sub];
                }
                dictM[it[@"bjID"]] = model;
            }
        }
        
        for (ClassModel *item in dictM.allValues) {
            if (item.subjects.length > 0) {
                [item.subjects deleteCharactersInRange:NSMakeRange(item.subjects.length - 1, 1)];
            }
            item.roleAndSubject = item.subjects.length > 0 ? [NSString stringWithFormat:@"%@  %@:%@", item.role, NSLocalizedString(@"科目", nil), item.subjects] : [NSString stringWithFormat:@"%@", item.role];
        }
        
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dd in array) {
            if ([dd[@"jsjs"] isEqualToString:@"01"]) {
                [WDTeacher sharedUser].masterList = dd[@"bjList"];
            }else {
                [arrayM addObject:dd];
            }
        }
        [WDTeacher sharedUser].teacherList = arrayM.copy;
        
        self.returnBlock(dictM.allValues);
    }];

}

@end
