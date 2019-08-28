//
//  WDLog.h
//  wdk12IPhone
//
//  Created by macapp on 15/12/8.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//
#ifndef WD_LOG_H
#define WD_LOG_H
#import <Foundation/Foundation.h>
#import "CocoaLumberjack.h"

//extern const int ddLogLevel;
#define  ddLogLevel  DDLogLevelDebug
#define WDLog(fmt,...) DDLogInfo(@"[%s-%d]" fmt,__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);
//#define WDLog(fmt,...) [WDLogToFile log_info:(fmt),##__VA_ARGS__];

void initLog();


#endif