//
//  WDCourseDetailModel.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDCourseDetailModel.h"

@implementation WDCourseDetailModel

+ (WDCourseDetailModel *)getCourseModelWith:(NSDictionary *)dict {
    return [[WDCourseDetailModel alloc] initWithDic:dict];
}

- (instancetype)initWithDic:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        [self setValuesForKeysWithDictionary:dict];

    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
