//
//  WDDescView.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/25.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "WDDescView.h"

@interface WDDescView ()


@end
@implementation WDDescView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)descView {
    return [[[NSBundle mainBundle] loadNibNamed:@"WDDescView" owner:nil options:nil] lastObject];
}

@end
