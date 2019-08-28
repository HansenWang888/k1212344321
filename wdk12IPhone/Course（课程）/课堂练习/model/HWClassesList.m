//
//  HMClassesList.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/24.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesList.h"

@implementation HWClassesList

+ (instancetype)classesListWithDict:(NSDictionary *)dict {
    HWClassesList *list = [HWClassesList new];
    [list setValuesForKeysWithDictionary:dict];
    NSLog(@"%@--%@---%@--",list.bjID,list.xsrs,list.bjmc);
    list.xsrs = [NSString stringWithFormat:@"%@",list.xsrs];
    return list;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}
@end
