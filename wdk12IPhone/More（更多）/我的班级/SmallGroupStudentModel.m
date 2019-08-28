//
//  SmallGroupStudentModel.m
//  小组及座位图
//
//  Created by 王振坤 on 16/6/2.
//  Copyright © 2016年 王振坤. All rights reserved.
//

#import "SmallGroupStudentModel.h"
#import "StudentModel.h"

@implementation SmallGroupStudentModel

+ (instancetype)objectWithDict:(NSDictionary *)dict {
    SmallGroupStudentModel *obj = [SmallGroupStudentModel new];

    obj.studentLists = [NSMutableArray array];

    obj.smallGroupName = dict[@"xzmc"];
    obj.id = dict[@"xzID"];
    NSArray *cyList = dict[@"cyList"];
    
    for (NSDictionary *item in cyList) {
        [obj.studentLists addObject:[StudentModel objectWithDict:item]];
    }
    
    return obj;
}

@end
