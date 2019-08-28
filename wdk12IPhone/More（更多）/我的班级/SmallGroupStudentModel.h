//
//  SmallGroupStudentModel.h
//  小组及座位图
//
//  Created by 王振坤 on 16/6/2.
//  Copyright © 2016年 王振坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmallGroupStudentModel : NSObject

/*!
 *  小组id
 */
@property (nonatomic, copy) NSString *id;
/*!
 *  学生列表
 */
@property (nonatomic, strong) NSMutableArray *studentLists;
/*!
 *  小组名
 */
@property (nonatomic, strong) NSString *smallGroupName;

///  是否选中
@property (nonatomic, assign) BOOL isSelect;

+ (instancetype)objectWithDict:(NSDictionary *)dict;

@end
