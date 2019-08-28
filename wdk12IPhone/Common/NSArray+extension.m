//
//  NSArray+extension.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/10/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "NSArray+extension.h"

@implementation NSArray (extension)

+ (NSMutableArray *)mutableArrayWith:(NSArray *)array {
    NSMutableArray *arrayM = @[].mutableCopy;
    
    for (id obj in array) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [arrayM addObject:[NSArray mutableArrayWith:obj]];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            [arrayM addObject:[NSDictionary mutableDictWith:obj]];
        } else if ([obj isKindOfClass:[NSNull class]]) {
            [arrayM addObject:@""];
        } else {
            [arrayM addObject:obj];
        }
    }
    return arrayM;
}

@end
