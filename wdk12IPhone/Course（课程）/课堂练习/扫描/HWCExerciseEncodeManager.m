//
//  HWCExerciseEncodeManager.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/26.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWCExerciseEncodeManager.h"

@implementation HWCExerciseEncodeManager

+ (instancetype)exerciseEncodeShareManager {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HWCExerciseEncodeManager new];
        dispatch_async(dispatch_get_main_queue(), ^{
            [manager analysisEncodeList];
        });
    });
    return manager;
}
- (void)analysisEncodeList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CExerciseEncode" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    NSArray *encodeList = dataDict[@"fbtbm"];
    _encodeDict = @{}.mutableCopy;
    [encodeList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_encodeDict setValue:obj forKey:obj[@"bmz"]];
    }];
}
@end
