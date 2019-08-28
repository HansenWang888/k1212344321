//
//  MoreHeaderView.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "MoreHeaderView.h"

@interface MoreHeaderView ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;


@end

@implementation MoreHeaderView

+ (instancetype)moreHeaderView{

    //setting!!!!!!!
    return [[[NSBundle mainBundle] loadNibNamed:@"MoreHeaderView" owner:nil options:nil] lastObject];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
