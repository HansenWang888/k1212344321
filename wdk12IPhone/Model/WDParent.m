//
//  WDParent.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/25.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDParent.h"
#import "NSDictionary+R.h"
#import "WDStudent.h"
@implementation WDParent

- (instancetype)initWithDict:(NSDictionary *)dict {
    NSDictionary *userInfo =  [dict recursiveObjectForKey:@"grxxxq"];
    if(!userInfo) return nil;
    NSString *parentID = [userInfo recursiveObjectForKey:@"jzID"];
    if(!parentID) return nil;
    if (self = [super initWithDict:userInfo]) {
        self.parentID = parentID;
        NSArray *listArray = [dict recursiveObjectForKey:@"xsList"];
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dd in listArray) {
            [arrayM addObject:[WDStudent studentWithDict:dd]];
        }
        self.studentList = arrayM.copy;
    }
    return self;
}
-(BOOL)isTeacher{
    return NO;
}
@end
