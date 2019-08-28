//
//  HWCExerciseEncodeManager.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/26.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWCExerciseEncodeManager : NSObject
/*
 bmz :@{
 "xh": "1",
 "xx": "A",
 "bmz": "36896"}
 */
@property (nonatomic, strong,readonly) NSMutableDictionary *encodeDict;

+ (instancetype)exerciseEncodeShareManager;
@end
