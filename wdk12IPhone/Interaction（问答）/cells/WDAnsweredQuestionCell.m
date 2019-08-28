//
//  WDAnsweredQuestionCell.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/17.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDAnsweredQuestionCell.h"
#import "WDQuestionModel.h"
#import "UIImageView+WebCache.h"

@interface WDAnsweredQuestionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *answerIcon;
@property (weak, nonatomic) IBOutlet UILabel *answerName;
@property (weak, nonatomic) IBOutlet UILabel *cainaLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerDate;

@property (nonatomic, strong) WDAnswerPersonModel *answerPersonModel;

@end

@implementation WDAnsweredQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setAnswerQuestionModel:(WDQuestionModel *)answerQuestionModel {
    _answerQuestionModel = answerQuestionModel;
    
    //头像 名字
    if ([_answerQuestionModel.sfnm isEqualToString:@"false"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_answerQuestionModel.icon] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        self.nameLabel.text = _answerQuestionModel.twr;
    }else {
        self.iconImageView.image = [UIImage imageNamed:@"default_touxiang"];
        self.nameLabel.text = NSLocalizedString(@"***", nil);
    }
    
    //回答人数
    self.answerNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"有%d个回答", nil),_answerQuestionModel.hds];
    
    //标题
    NSString *titleStr = [_answerQuestionModel.wtlx isEqualToString:@"2"] ? _answerQuestionModel.ztzt : _answerQuestionModel.wtwz;
    if (!titleStr || !titleStr.length) {
        titleStr = NSLocalizedString(@"图片问题", nil);
    }
    NSString *str1 = [NSString stringWithFormat:@"%@%@%@", @"<html><body>", titleStr, @"</body><style>body{font-size: 13px;font-weight:bold}</style></html>"];
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithData:[str1 dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.titleLabel.attributedText = attr1;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;
    
    //科目
    self.courseLabel.text = [NSString stringWithFormat:@"%@%@%@",_answerQuestionModel.km,_answerQuestionModel.nj,_answerQuestionModel.cb];
    
    //问题类型
    if ([_answerQuestionModel.wtlx isEqualToString:@"1"]) {
        self.courseTypeLabel.text = NSLocalizedString(@"课程疑问", nil);
        self.courseTypeLabel.textColor = [UIColor hex:0xF7B964 alpha:1];
    }else if ([_answerQuestionModel.wtlx isEqualToString:@"2"]) {
        self.courseTypeLabel.text = NSLocalizedString(@"专题讨论", nil);
        self.courseTypeLabel.textColor = [UIColor hex:0x61B961 alpha:1];
    }else if ([_answerQuestionModel.wtlx isEqualToString:@"3"]) {
        self.courseTypeLabel.text = NSLocalizedString(@"其他问题", nil);
        self.courseTypeLabel.textColor = [UIColor hex:0xA453CE alpha:1];
    }
    
    //回答人
    
    //头像
    if (_answerQuestionModel.cnList.count) {
        _answerPersonModel = [_answerQuestionModel.cnList firstObject];
    }
    [self.answerIcon sd_setImageWithURL:[NSURL URLWithString:_answerPersonModel.hdrIcon] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
    //名字
    self.answerName.text = _answerPersonModel.hdr;
    
    if ([_answerPersonModel.sfcn isEqualToString:@"true"]) {
        self.cainaLabel.text = NSLocalizedString(@"已采纳", nil);
    }else {
        self.cainaLabel.text = @"";
    }
    
    //采纳时间
    self.answerDate.text = _answerPersonModel.hdrq;
    NSString *answer = @"";
    if (!_answerPersonModel.hdwz.length) {
        answer = NSLocalizedString(@"图片回答", nil);
    }else {
        answer = _answerPersonModel.hdwz;
    }
    self.answerTextView.text = answer;
}

@end
