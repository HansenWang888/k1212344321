//
//  WDTeacher.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/25.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDTeacher.h"
#import "NSDictionary+R.h"
@implementation WDTeacher


- (instancetype)initWithDict:(NSDictionary *)dict {

    NSDictionary* userInfo =  [dict recursiveObjectForKey:@"grxxxq"];
    if(!userInfo) return nil;
    NSString* teacherid = [userInfo recursiveObjectForKey:@"jsID"];
    NSString * schoolId = [userInfo recursiveObjectForKey:@"xxID"];
    if(!teacherid) return nil;
    if (self = [super initWithDict:userInfo]) {
        self.teacherID = teacherid;
        self.schoolID = schoolId;
        NSArray *jsjs = [dict recursiveObjectForKey:@"jsjsxxList"];
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dd in jsjs) {
            if ([[dd recursiveObjectForKey:@"jsjs"] isEqualToString:@"01"] && jsjs != nil) {
                self.masterList = dd[@"bjList"];
            }else {
                [arrayM addObject:dd];
            }
        }
        self.teacherList = arrayM.copy;
    }
    return self;
}

-(BOOL)isTeacher{
    return YES;
}
@end
