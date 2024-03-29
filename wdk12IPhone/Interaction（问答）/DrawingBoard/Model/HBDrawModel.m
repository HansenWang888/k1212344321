//
//  HBDrawModel.m
//  DemoAntiAliasing
//
//  Created  on 15/11/9.
//  Copyright © 2015年 HB. All rights reserved.
//

#import "HBDrawModel.h"
#import "HBDrawPoint.h"
#import "MJExtension.h"
#import "HBDrawCommon.h"


@implementation HBDrawModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.action = Action_playing;
        self.width = @([UIScreen mainScreen].bounds.size.width);
        self.width = @([UIScreen mainScreen].bounds.size.height);
    }
    return self;
}
+ (NSDictionary *)objectClassInArray
{
    return @{@"pointList": [HBDrawPoint class]};
}

@end
