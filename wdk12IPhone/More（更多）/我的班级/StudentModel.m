//
//  StudentModel.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "StudentModel.h"

@implementation StudentModel

+ (instancetype)objectWithDict:(NSDictionary *)dict {
    StudentModel *obj = [StudentModel new];
    obj.name = dict[@"xsxm"];
    obj.id = dict[@"xsID"];
    
    if (dict[@"xszp"] != nil) {
        obj.iconImage = [NSString stringWithFormat:@"%@/%@", FILE_SEVER_DOWNLOAD_URL,dict[@"xszp"]];
    }
    
    if (obj.iconImage == nil || [obj.iconImage isEqualToString:@""]) {
        obj.iconImage = dict[@"tx"];
    }
    
    return obj;
}

@end
