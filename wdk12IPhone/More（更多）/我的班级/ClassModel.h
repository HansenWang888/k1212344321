//
//  ClassModel.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

///  班级模型
@interface ClassModel : NSObject

///  班级id
@property (nonatomic, copy) NSString *id;
///  班级名称
@property (nonatomic, copy) NSString *name;
///  科目列表
@property (nonatomic, strong) NSMutableString *subjects;
///  教师角色
@property (nonatomic, copy) NSString *role;
///  教师角色编码
@property (nonatomic, strong) NSMutableSet *roleCode;
///  角色和科目
@property (nonatomic, copy) NSString *roleAndSubject;
///  班级总人数
@property (nonatomic, assign) NSInteger count;
///  男生人数
@property (nonatomic, assign) NSInteger man;
///  女生人数
@property (nonatomic, assign) NSInteger woman;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, copy) NSString *jsjs;

@property (nonatomic, strong) NSMutableArray *kmList;

+ (instancetype)objectWithDict:(NSDictionary *)dict;

@end
