//
//  WDAnswerDetailModel.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDAnswerDetailModel.h"

@implementation WDAnswerDetailModel

+ (WDAnswerDetailModel *)getAnswerDetailModelWith:(NSDictionary *)dict {
    
    WDAnswerDetailModel *model = [[WDAnswerDetailModel alloc] initWithDic:dict];
    if (model.hfxxList.count) {
        NSMutableArray *temArr = @[].mutableCopy;
        for (NSDictionary *ddc in model.hfxxList) {
            WDAnswerDetailModel *secModel = [[WDAnswerDetailModel alloc] initWithDic:ddc];
            [temArr addObject:secModel];
        }
        model.hfxxList = temArr;
    }
    return model;
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
