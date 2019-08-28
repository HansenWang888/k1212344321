//
//  HWClassesStudentList.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/26.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesStudentList.h"

@implementation HWClassesStudentList

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self  setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+(instancetype)classesStudentListWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}
@end
