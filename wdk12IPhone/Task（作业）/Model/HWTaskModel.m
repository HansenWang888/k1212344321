//
//  HWTaskModel.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWTaskModel.h"

@implementation HWTaskModel

+ (HWTaskModel *)objectWithDict:(NSDictionary *)dict {
    HWTaskModel *obj = [HWTaskModel new];
    [obj setValuesForKeysWithDictionary:dict];
    return obj;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
