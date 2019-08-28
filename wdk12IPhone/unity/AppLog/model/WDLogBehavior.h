//
//  WDLogBehavior.h
//  行为日志
//
//  Created by 老船长 on 2017/5/16.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    OperationTypeIn = 1,
    OperationTypeOut = 2
}OperationType;

@interface WDLogBehavior : NSObject
@property (nonatomic, copy) NSString *id;//相当于这条数据的主键

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *lastPageName;
@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, copy) NSString *widgetName;
@property (nonatomic, copy) NSString *operType;//操作类型根据OperationType进行设置
@property (nonatomic, copy) NSString *operateTime;
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *endInfo;
@property (nonatomic, copy) NSString *endOs;
@property (assign, nonatomic) OperationType type;

//@property (nonatomic, copy) void(^finishedBlock)(WDLogBehavior *);//表示已经形成一段完整的行为日志数据
+ (instancetype)createLogger;
@end
