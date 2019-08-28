//
//  WDQuestionCell.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDQuestionCell.h"
#import "WDQuestionModel.h"
#import "UIImageView+WebCache.h"

@interface WDQuestionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionTypeLabel;

@end

@implementation WDQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setQuestionModel:(WDQuestionModel *)questionModel {
    _questionModel = questionModel;
    NSLog(@"%@",_questionModel.twr);
    
    //头像 名字
    if ([_questionModel.sfnm isEqualToString:@"false"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_questionModel.icon] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        self.nameLabel.text = _questionModel.twr;
    }else {
        self.iconImageView.image = [UIImage imageNamed:@"default_touxiang"];
        self.nameLabel.text = NSLocalizedString(@"***", nil);
    }
    
    //回答人数
    self.answerNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"有%d个回答", nil),_questionModel.hds];

    //标题
    NSString *titleStr = [_questionModel.wtlx isEqualToString:@"2"] ? _questionModel.ztzt : _questionModel.wtwz;
    if (!titleStr || !titleStr.length) {
        titleStr = NSLocalizedString(@"图片问题", nil);
    }

    self.titleLabel.text = titleStr;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    //科目
    self.courseLabel.text = [NSString stringWithFormat:@"%@%@%@%@",_questionModel.km,_questionModel.nj,_questionModel.cb,_questionModel.jcbbmc];
    
    //时间
    self.dateLabel.text = _questionModel.twrq;
    
    //问题类型
    if ([_questionModel.wtlx isEqualToString:@"1"]) {
        self.questionTypeLabel.text = NSLocalizedString(@"课程疑问", nil);
        self.questionTypeLabel.textColor = [UIColor hex:0xF7B964 alpha:1];
    }else if ([_questionModel.wtlx isEqualToString:@"2"]) {
        self.questionTypeLabel.text = NSLocalizedString(@"专题讨论", nil);
        self.questionTypeLabel.textColor = [UIColor hex:0x61B961 alpha:1];
    }else if ([_questionModel.wtlx isEqualToString:@"3"]) {
        self.questionTypeLabel.text = NSLocalizedString(@"其他问题", nil);
        self.questionTypeLabel.textColor = [UIColor hex:0xA453CE alpha:1];
    }
    
}

@end
