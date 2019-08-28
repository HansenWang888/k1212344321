//
//  ChatRecordPromtView.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "ChatRecordPromtView.h"

@interface ChatRecordPromtView ()
@property (nonatomic, strong) CADisplayLink *link;

@end
@implementation ChatRecordPromtView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    self.label.text = IMLocalizedString(@"手指上滑，直接取消", nil);
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.imageLable.text = @"\U0000e668";
}
- (void)linkFire {
    [UIView animateWithDuration:1.0 animations:^{
        self.imageLable.alpha = 0.3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.imageLable.alpha = 1.0;
        }];
    }];
   
}
- (void)showView {
    self.hidden = NO;
    if (self.link.isPaused) {
        [self.link setPaused:NO];
        return;
    }
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)hiddenView {
    self.hidden = YES;
    [self.link setPaused:YES];
    
}
+ (instancetype)recordPromtView {
    return [[[NSBundle mainBundle] loadNibNamed:@"ChatRecordPromtView" owner:nil options:nil] lastObject];
}
- (CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkFire)];
        _link.frameInterval = 120;
    }
    return _link;
}
- (void)dealloc {
    [self.link invalidate];
    self.link = nil;
}
@end
