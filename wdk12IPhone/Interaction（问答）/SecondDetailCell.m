//
//  SecondDetailCell.m
//  wdk12IPhone
//
//  Created by cindy on 15/11/5.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "SecondDetailCell.h"

@implementation SecondDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)interactionCell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"SecondDetailCell" owner:nil options:nil] lastObject];
}
@end
