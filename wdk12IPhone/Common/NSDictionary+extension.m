//
//  NSDictionary+extension.m
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/10/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "NSDictionary+extension.h"

@implementation NSDictionary (extension)

+ (NSMutableDictionary *)mutableDictWith:(NSDictionary *)dict {
    NSMutableDictionary *dictM = @{}.mutableCopy;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayM = [NSMutableArray array];
            for (id item in obj) {
                if ([item isKindOfClass:[NSArray class]]) {
                    [arrayM addObject:[NSArray mutableArrayWith:item]];
                } else if ([item isKindOfClass:[NSDictionary class]]) {
                    [arrayM addObject:[NSDictionary mutableDictWith:item]];
                } else if ([item isKindOfClass:[NSNull class]]) {
                    [arrayM addObject:@""];
                } else {
                    [arrayM addObject:item];
                }
            }
            dictM[key] = arrayM;
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            dictM[key] = [NSDictionary mutableDictWith:obj];
        } else if ([obj isKindOfClass:[NSNull class]]) {
            dictM[key] = @"";
        } else {
            dictM[key] = [NSString stringWithFormat:@"%@", obj];
        }
    }];
    return dictM;
}

- (NSDictionary *)nullToStringWithDict:(NSDictionary *)dict {
    NSMutableDictionary *dictM = @{}.mutableCopy;
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = @"";
            dictM[key] = obj;
        } else if([obj isKindOfClass:[NSArray class]]){
            obj = [self nullToStringWithArray:obj];
            dictM[key] = obj;
            
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            obj = [self nullToStringWithDict:obj];
            dictM[key] = obj;
        } else {
            dictM[key] = obj;
        }
    }];
    return dictM.copy;
}
- (NSArray *)nullToStringWithArray:(NSArray *)array {
    NSMutableArray *nArray = @[].mutableCopy;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [nArray addObject:[self nullToStringWithDict:obj]];
        }
    }];
    return nArray.copy;
}

@end
