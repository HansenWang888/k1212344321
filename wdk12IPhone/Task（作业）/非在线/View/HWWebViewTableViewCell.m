//
//  HWWebViewTableViewCell.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/10.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "HWWebViewTableViewCell.h"

@implementation HWWebViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.webView = [UIWebView new];
    [self.contentView addSubview:self.webView];
    self.webView.scrollView.scrollEnabled = false;
//    self.webView.scalesPageToFit = true;
}

- (void)initAutoLayout {
    [self.webView zk_Fill:self.contentView insets:UIEdgeInsetsZero];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}


@end
