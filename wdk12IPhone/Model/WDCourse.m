//
//  WDCourse.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/28.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDCourse.h"
#import "WDCourseList.h"
#import "WDCourseSQL.h"
#import "WDHTTPManager.h"
@implementation WDCourse

+ (instancetype)coureseWithDict:(NSDictionary *)dict {
    
    WDCourse *course = [self new];
    course.timeBucket = dict[@"zxsjd"];
    for (NSDictionary *dd in dict[@"zxxxList"]) {
       [course.courseLists addObject:[WDCourseList listWithDict:dd]];
    }
    return course;
}

- (void)loadCourseDescriptionWithDateStr:(NSString *)dateStr ID:(NSString *)ID paramKey:(NSString *)key method:(NSString *)method isSQL:(BOOL)isSQL finished:(void (^)(NSArray *))finished{
    
    NSMutableArray *arrayM = [NSMutableArray array];

    [[WDHTTPManager sharedHTTPManeger] loadMyCourseListWithID:ID date:dateStr paramKey:key method:method finished:^(NSDictionary *dict) {
        if (dict) {
            for (NSDictionary *dd in dict[@"zxnrList"]) {
                [arrayM addObject:[WDCourse coureseWithDict:dd]];
            }
            finished(arrayM);
            return;
        }
        finished(nil);
    }];
}
- (NSMutableArray *)courseLists {
    
    if (!_courseLists) {
        _courseLists  = [NSMutableArray array];
    }
    return _courseLists;
}

@end
