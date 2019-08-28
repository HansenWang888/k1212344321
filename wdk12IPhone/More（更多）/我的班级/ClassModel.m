//
//  ClassModel.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "ClassModel.h"

@implementation ClassModel

+ (instancetype)objectWithDict:(NSDictionary *)dict {
    ClassModel *obj = [ClassModel new];
    obj.id = dict[@"bjID"];
    obj.name = dict[@"bjmc"];
    return obj;
}

@end
