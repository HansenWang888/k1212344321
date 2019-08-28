//
//  HWClassesChoiceItem.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/25.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesChoiceItem.h"

@implementation HWClassesChoiceItem

+ (instancetype)choiceItemView {
    return [[[NSBundle mainBundle] loadNibNamed:@"HWClassesChoiceItem" owner:nil options:nil] lastObject];
}
@end
