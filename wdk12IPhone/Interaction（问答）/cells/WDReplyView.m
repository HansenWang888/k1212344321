//
//  WDReplyView.m
//  wdk12IPhone
//
//  Created by 官强 on 16/12/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "WDReplyView.h"

@interface WDReplyView ()


@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation WDReplyView


- (void)reset {
    _textView.text = @"";
    [_textView resignFirstResponder];
}

- (void)becomeFirstResponder {
    [_textView becomeFirstResponder];
}

- (IBAction)closeClicked:(id)sender {
    if (_closeBlock) {
        _closeBlock();
    }
}

- (IBAction)confirmClicked:(id)sender {
    if (_confirmBlock) {
        _confirmBlock(_textView.text);
    }
}

@end
