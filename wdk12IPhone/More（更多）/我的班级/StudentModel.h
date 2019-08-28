//
//  StudentModel.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/20.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "ViewModelClass.h"

@interface StudentModel : NSObject

///  头像
@property (nonatomic, copy) NSString *iconImage;
///  姓名
@property (nonatomic, copy) NSString *name;
///  所属班级的id
@property (nonatomic, copy) NSString *classId;
///  id
@property (nonatomic, copy) NSString *id;
///  是否选中
@property (nonatomic, assign) BOOL isSelect;
///  学生答案
@property (nonatomic, strong) NSMutableArray *snwerArray;

+ (instancetype)objectWithDict:(NSDictionary *)dict;

@end
