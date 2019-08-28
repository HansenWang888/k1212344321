//
//  AnalysisTableViewCell.m
//  wdk12pad
//
//  Created by 王振坤 on 16/7/25.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "HomeworkOtherAnalysisCell.h"

@implementation HomeworkOtherAnalysisCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
        self.backgroundColor = [UIColor clearColor];//COLOR_Creat(94, 94, 94, 1);
        self.analysisLabel.textColor = COLOR_Creat(248, 255, 255, 1);
        self.analysisContentLabel.textColor = self.analysisLabel.textColor;
    }
    return self;
}

- (void)initView {
    self.analysisLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x5EBF6D alpha:1.0] font:[UIFont systemFontOfSize:17] alpha:1.0];
    self.analysisContentLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15] alpha:1.0];
    self.analysisContentLabel.numberOfLines = 0;
    [self.contentView addSubview:self.analysisLabel];
    [self.contentView addSubview:self.analysisContentLabel];
}

- (void)initAutoLayout {
    [self.analysisLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.analysisContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.analysisLabel.mas_left).offset(10);
        make.right.offset(-10);
        make.top.equalTo(self.analysisLabel.mas_bottom).offset(0);
    }];
}

- (void)setValueForDataSource:(NSString *)data {
    
    NSString *str = [NSString stringWithFormat:@"<html><body>%@</body><style>body,html{font-size: 16px;color:white;width:100%%;}img{max-width:%f !important;height: auto !important;}</style></html>", data, [UIScreen wd_screenWidth] - 80];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.analysisContentLabel.attributedText = attr;
    self.analysisContentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 80;
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

@end
