//
//  HomeworkTopicCell.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HomeworkTopicCell.h"

@implementation HomeworkTopicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.typeLabel.layer.cornerRadius = 3;
//    self.typeLabel.layer.masksToBounds = YES;
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 20;
}
+ (instancetype)selfCell {
    return [[[NSBundle mainBundle] loadNibNamed:@"HomeworkTopicCell" owner:nil options:nil] lastObject];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

- (void)setValueForDataSource:(NSString *)data xh:(NSString *)btxh fz:(NSString *)fz {
    
    if (fz) {
        if (![[NSString stringWithFormat:@"%ld", [fz integerValue]] isEqualToString:@""]) {
            self.countScore.text = [NSString stringWithFormat:@"(%@：%ld)",NSLocalizedString(@"本题总分", nil), [fz integerValue]];
        }
    }
    
    NSString *pxbh = [btxh isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@", btxh];
    NSString *str = [NSString stringWithFormat:@"%@%@%@</body><style>body,html{font-size: 14px;width:100%%;color: white;font-weight:bold} img{max-width:%f !important;}</style></html>",pxbh, @"<html><body>", data, [UIScreen wd_screenWidth] - 20];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.contentLabel.attributedText = attr;
    [self.contentView layoutIfNeeded];
}
@end
