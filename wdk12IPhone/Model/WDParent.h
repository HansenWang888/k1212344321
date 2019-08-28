//
//  WDParent.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/25.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDUser.h"

@interface WDParent : WDUser

@property (nonatomic, copy) NSString *parentID;//老师ID
@property (nonatomic, copy) NSArray *studentList;//家长的所有孩子

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
