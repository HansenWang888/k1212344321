//
//  WDAnswerDetailCell.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDAnswerDetailCell.h"
#import "WDAnswerDetailModel.h"
#import "UIImageView+WebCache.h"

@interface WDAnswerDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cainaLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *huifuBtn;
@property (weak, nonatomic) IBOutlet UIButton *cainaBtn;

@property (nonatomic, strong) WDAnswerDetailModel *detailModel;

@end

@implementation WDAnswerDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setCellWithModel:(WDAnswerDetailModel *)model isFirst:(BOOL)isFirst isMe:(BOOL)isMe {

   if (!model)  return;
    
    _detailModel = model;
    
    //采纳按钮 label
    if (isFirst) {
        
        self.huifuBtn.hidden = NO;
        self.cainaLabel.hidden = NO;
        //是否采纳
        if ([model.sfcn isEqualToString:@"true"]) {
            self.cainaBtn.hidden = YES;
            self.cainaLabel.hidden = NO;
        }else {
            self.cainaLabel.hidden = YES;
            if (isMe) {
                self.cainaBtn.hidden = NO;
            }else {
                self.cainaBtn.hidden = YES;
            }
        }
        
        //头像
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.hdrIcon] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        
        //名字
        self.nameLabel.text = model.hdr;
        
        //日期
        self.dateLabel.text = model.hdrq;
        
        //回答正文
        NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 13px;width:100%%;}img{max-width:%f !important;}</style></html>", model.hdfwbnr, [UIScreen wd_screenWidth] - 150];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        self.contentLabel.attributedText = attr;
        self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;
        
    }else {
    
        self.cainaBtn.hidden = YES;
        self.huifuBtn.hidden = YES;
        self.cainaLabel.hidden = YES;

        //头像
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.hfrIcon] placeholderImage:[UIImage imageNamed:@"default_touxiang"]];
        
        //名字
        self.nameLabel.text = model.hfr;
        
        //日期
        self.dateLabel.text = model.hfrq;

        //回答正文
        self.contentLabel.text = model.hfnr;
        self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 150;
    }
    
    if (self.isCaiNa) {
        self.cainaBtn.hidden = YES;
    }
}

//回复
- (IBAction)huifuBtnClicked:(id)sender {
    if (_huifuBlock) {
        _huifuBlock(self.detailModel);
    }
}
//采纳
- (IBAction)cainaBtnClicked:(id)sender {
    if (_cainaBlock) {
        _cainaBlock(self.detailModel);
    }
}

@end
