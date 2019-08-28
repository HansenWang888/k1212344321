//
//  HWTaskTimerModel.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/8.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWTaskTimerModel.h"

@implementation HWTaskTimerModel

//- (void)setDate:(NSDate *)date {
//    _date = date;
//    
//    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
//    dateFormater.dateFormat = @"yyyy-MM-dd hh:mm";
//    dateFormater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
//    self.time = [NSString stringWithFormat:@"%@", [dateFormater stringFromDate:date]];
//}

//- (NSString *)time {
//    if (_time) {
//        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
//        dateFormater.dateFormat = @"yyyy-MM-dd hh:mm";
//        dateFormater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
//        _time = [NSString stringWithFormat:@"%@", [dateFormater stringFromDate:_date]];
//    }
//    return _time;
//}

- (void)setDate:(NSDate *)date {
    _date = date;
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd hh:mm";
    //    dateFormater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    self.time = [NSString stringWithFormat:@"%@", [dateFormater stringFromDate:date]];
}


//- (NSDate *)date {
//    if (_date) {
//        _date = [NSDate date];
////        NSTimeZone *zone = [NSTimeZone systemTimeZone];
////        NSInteger interval = [zone secondsFromGMTForDate: date];
////        _date = [date dateByAddingTimeInterval:interval];
//    }
//    return _date;
//}

@end
