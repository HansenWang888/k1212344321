//
//  interactionDetailCell.m
//  wdk12IPhone
//
//  Created by cindy on 15/11/3.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "interactionDetailCell.h"

@implementation interactionDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)interactionCell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"interactionDetailCell" owner:nil options:nil] lastObject];
}

@end
