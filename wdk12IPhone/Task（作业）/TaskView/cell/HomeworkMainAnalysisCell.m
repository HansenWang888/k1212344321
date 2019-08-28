//
//  HomeworkMainAnalysisCell.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HomeworkMainAnalysisCell.h"


@implementation HomeworkMainAnalysisCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setStnydWithNumber:(int)num {

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)selfCell {
    return [[[NSBundle mainBundle] loadNibNamed:@"HomeworkMainAnalysisCell" owner:nil options:nil] lastObject];
}
@end
