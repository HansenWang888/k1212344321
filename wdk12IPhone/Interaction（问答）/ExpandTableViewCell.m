//
//  ExpandTableViewCell.m
//  wdk12IPhone
//
//  Created by cindy on 15/10/30.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "ExpandTableViewCell.h"

@implementation ExpandTableViewCell

- (void)awakeFromNib {
    self.myTitle.adjustsFontSizeToFitWidth = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)interactionCell
{
     return [[[NSBundle mainBundle] loadNibNamed:@"ExpandTableViewCell" owner:nil options:nil] lastObject];
}

@end
