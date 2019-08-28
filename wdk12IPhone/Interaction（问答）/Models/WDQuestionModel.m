//
//  WDQuestionModel.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDQuestionModel.h"
@class WDAnswerPersonModel;
@implementation WDQuestionModel

+ (WDQuestionModel *)getQuestionModelWith:(NSDictionary *)dict {
    return [[WDQuestionModel alloc] initWithDic:dict];
}

- (instancetype)initWithDic:(NSDictionary *)dict
{
    self = [super init];
    if (self) {

        [self setValuesForKeysWithDictionary:dict];
        _questionId = dict[@"id"];
        NSMutableArray *temArr = @[].mutableCopy;
        if (_cnList.count) {
            for (NSDictionary *dic in _cnList) {
                WDAnswerPersonModel *model = [WDAnswerPersonModel getQuestionPersonModelWith:dic];
                [temArr addObject:model];
            }
        }
        _cnList = temArr;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

@end

@implementation WDAnswerPersonModel

+ (WDAnswerPersonModel *)getQuestionPersonModelWith:(NSDictionary *)dict {
    return [[WDAnswerPersonModel alloc] initWithDic:dict];
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
