//
//  SelectionTableViewCell.m
//  wdk12pad
//
//  Created by 王振坤 on 16/7/23.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "HomeworkChoiceCell.h"
//#import "ProblemOption.h"

@interface HomeworkChoiceCell ()

///  基线
@property (nonatomic, strong) UIView *baselineView;
///  选中label
@property (nonatomic, strong) UILabel *selectLabel;

@end

@implementation HomeworkChoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.serialNumButton = [UIButton buttonWithFont:[UIFont systemFontOfSize:17] title:@"A" titleColor:COLOR_Creat(234, 141, 36, 1) backgroundColor:nil];
    self.serialNumButton.layer.borderColor = COLOR_Creat(234, 141, 36, 1).CGColor;
    self.contentLabel = [UILabel new];
    self.baselineView = [UIView viewWithBackground:[UIColor blackColor] alpha:0.5];
    [self.contentView addSubview:self.serialNumButton];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.baselineView];
    
    self.serialNumButton.layer.cornerRadius = 30 * 0.5;
    self.serialNumButton.layer.masksToBounds = true;
    self.serialNumButton.layer.borderWidth = 1.0;
    self.serialNumButton.userInteractionEnabled = false;
    
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 90;
    self.contentLabel.numberOfLines = 0;
}

- (void)initAutoLayout {
    [self.serialNumButton zk_AlignInner:ZK_AlignTypeCenterLeft referView:self.contentView size:CGSizeMake(30, 30) offset:CGPointMake(30, 0)];
    [self.contentLabel zk_AlignHorizontal:ZK_AlignTypeCenterRight referView:self.serialNumButton size:CGSizeZero offset:CGPointMake(20, 0)];
    [self.baselineView zk_AlignInner:ZK_AlignTypeBottomCenter referView:self.contentView size:CGSizeMake([UIScreen wd_screenWidth] - 20, 0.5) offset:CGPointZero];
}

- (void)setValueForDataSource:(NSDictionary *)dict {
    NSString *str1 = [dict[@"xxnr"] stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    NSString *str3 = [self deleteBRWith:str2];
    [self.serialNumButton setTitle:dict[@"xxxh"] forState:UIControlStateNormal];
    NSString *str = [NSString stringWithFormat:@"%@%@</body><style>body,html{font-size: 16px;width:100%%;}img{max-width:%f !important;}</style></html>", @"<html><body>", str3, [UIScreen wd_screenWidth] - 100];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.contentLabel.attributedText = attr;
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen wd_screenWidth] - 100;
    [self.contentView layoutIfNeeded];
}

- (NSString *)deleteBRWith:(NSString *)str {
    
    NSMutableString *strM = str.mutableCopy;
    for (NSInteger i = strM.length; i != 0; i--) {
        if (![[strM substringWithRange:NSMakeRange(i - 1, 1)] isEqualToString:@" "] && ![[strM substringWithRange:NSMakeRange(i - 5, 5)] isEqualToString:@"<br/>"]) {
            break ;
        }
        if ([[strM substringWithRange:NSMakeRange(i - 1, 1)] isEqualToString:@" "]) {
            [strM deleteCharactersInRange:NSMakeRange(i - 1, 1)];
        } else { // 不为空
            if ([[strM substringWithRange:NSMakeRange(i - 5, 5)] isEqualToString:@"<br/>"]) {
                [strM deleteCharactersInRange:NSMakeRange(i - 5, 5)];
                i -= 4;
            }
        }
    }
    return strM;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    
    if (isSelect) {
        self.serialNumButton.layer.borderColor = COLOR_Creat(249, 101, 33, 1).CGColor;
        [self.serialNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.serialNumButton.backgroundColor = [UIColor hex:0xFF4E00 alpha:1.0];
    } else {
        self.serialNumButton.layer.borderColor = COLOR_Creat(234, 141, 36, 1) .CGColor;
        [self.serialNumButton setTitleColor:[UIColor hex:0xFF4E00 alpha:1.0] forState:UIControlStateNormal];
        self.serialNumButton.backgroundColor = [UIColor whiteColor];
    }
}



@end
