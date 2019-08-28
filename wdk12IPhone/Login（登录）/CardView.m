//
//  CardView.m
//  VideoWelcome
//
//  Created by 王晨晓 on 15/7/16.
//  Copyright (c) 2015年 Chinsyo. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (instancetype)init {
    if (self = [super init]) {
        CGRect frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height*2.0/3.0);
        self = [[CardView alloc] initWithFrame:frame];
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
        CGSize size = [UIScreen mainScreen].bounds.size;
        for (int i = 0; i < 2; i++) {
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, size.width - 40, 30)];
            field.borderStyle = UITextBorderStyleRoundedRect;
            field.center = CGPointMake(self.frame.size.width/2.0, size.height / 2 + i * 50);
            field.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6f];
            field.placeholder = i ? NSLocalizedString(@"请输入密码", nil) : NSLocalizedString(@"请输入帐户名", nil);
            field.secureTextEntry = i ? YES : NO;
            field.keyboardAppearance = UIKeyboardAppearanceDark;
            if (!i) {
                self.username = field;
            } else {
                self.password = field;
            }
            [self addSubview:field];
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        [subview resignFirstResponder];
    }
}
@end
