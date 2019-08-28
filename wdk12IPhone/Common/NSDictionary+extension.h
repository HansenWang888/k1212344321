//
//  NSDictionary+extension.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/10/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (extension)

+ (NSMutableDictionary *)mutableDictWith:(NSDictionary *)dict;
//将字典中的所有null对象变成空字符串
- (NSDictionary *)nullToStringWithDict:(NSDictionary *)dict;

@end
