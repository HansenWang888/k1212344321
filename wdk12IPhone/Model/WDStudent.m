//
//  WDStudent.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/11/10.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDStudent.h"

@implementation WDStudent

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.classesList = dict[@"bjList"];
        self.account = dict[@"zh"];
        self.headPhoto = dict[@"tx"];
        self.infoID = dict[@"xxID"];
        self.studentID = dict[@"xsID"];
        self.studentName = dict[@"xsxm"];
        self.PCRelation = dict[@"qzgx"];
    }
    return self;
}
+ (instancetype)studentWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}
@end
