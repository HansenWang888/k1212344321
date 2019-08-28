//
//  HWSubject.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWSubject.h"
#import "WDMB.h"

@implementation HWSubject

+ (instancetype)subjectWithDict:(NSDictionary *)dict {
    HWSubject *obj = [HWSubject new];
    obj.subjectID = dict[@"kmID"];
    NSDictionary *subjects = [WDMB MBToSubject];
    obj.subjectCH = subjects[obj.subjectID];
    return obj;
}

+ (instancetype)subjectWithDictIDAndMC:(NSDictionary *)dict {
    HWSubject *obj = [HWSubject new];
    obj.subjectID = dict[@"kmID"];
    obj.subjectCH = dict[@"kmmc"];
    return obj;
}

@end
