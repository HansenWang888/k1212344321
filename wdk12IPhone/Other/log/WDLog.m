//
//  WDLog.m
//  wdk12IPhone
//
//  Created by macapp on 15/12/8.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "WDLog.h"


//static const int

void initLog(){
    DDTTYLogger* tty = [[DDTTYLogger alloc]init];
    [DDLog addLogger:tty];
    NSString* homedic =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                          objectAtIndex:0];
    
    
    NSString* logdic = [homedic stringByAppendingPathComponent:@"log"];
    DDLogFileManagerDefault* dm = [[DDLogFileManagerDefault alloc]initWithLogsDirectory:logdic];
    NSLog(@"日志:%@",logdic);
    DDFileLogger* flogger = [[DDFileLogger alloc]initWithLogFileManager:dm];
    [DDLog addLogger:flogger];
}

//void WDLog(NSString* format,...){
// //   NSArray* array = [NSArray alloc]initWithObjects:@"aa", nil];
//}
