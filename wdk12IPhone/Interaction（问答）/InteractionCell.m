//
//  InteractionCell.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "InteractionCell.h"

@interface InteractionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImg;//用户图片
@property (weak, nonatomic) IBOutlet UILabel *userName;//用户名字
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//用户标题
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;//日期
@property (weak, nonatomic) IBOutlet UILabel *courseDesc;//课程
@property (weak, nonatomic) IBOutlet UILabel *answerGenre;//问题类型


@end

@implementation InteractionCell

+ (instancetype)interactionCell{

    return [[[NSBundle mainBundle] loadNibNamed:@"InteractionCell" owner:nil options:nil] lastObject];
}
@end
