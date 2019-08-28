//
//  WDLogBehaviorManager.h
//  行为日志
//
//  Created by 老船长 on 2017/5/16.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WDLogBehaviorManager : NSObject
+ (instancetype)logManager;
+ (void)uploadLoggerFinished:(void(^)(BOOL))finished;
+ (void)deleteLogSQlite;
@end
