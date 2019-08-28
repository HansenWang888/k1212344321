//
//  ClassSmallListModel.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 6/29/16.
//  Copyright © 2016 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassSmallListModel : NSObject

///  是否是当前学期
@property (nonatomic, assign) BOOL isCurrentTerm;
///  小组列表
@property (nonatomic, strong) NSMutableArray *smallGroupList;

//+ (instancetype)objectWithDict:(NSDictionary *)dict;

@end
