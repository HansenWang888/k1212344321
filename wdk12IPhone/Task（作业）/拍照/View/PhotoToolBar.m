//
//  PhotoToolBar.m
//  wdk12IPhone
//
//  Created by 官强 on 2017/7/11.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "PhotoToolBar.h"

@implementation PhotoToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self commit];
        
    }
    return self;
}

- (void)setIsFeedBack:(BOOL)isFeedBack {
    _isFeedBack = isFeedBack;
    
    if (isFeedBack) {
        
        UITabBarItem *one = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"清除反馈", nil) image:[UIImage imageNamed:@"photoTool_one"] selectedImage:nil];
        
        UITabBarItem *two = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"重新反馈", nil) image:[UIImage imageNamed:@"photoTool_second"] selectedImage:nil];
        
        UITabBarItem *three = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"原图", nil) image:[UIImage imageNamed:@"photoTool_three"] selectedImage:nil];
        
        [self setItems:@[one,two,three] animated:YES];
        
    }else {
        
        UITabBarItem *two = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"添加反馈", nil) image:[UIImage imageNamed:@"photoTool_second"] selectedImage:nil];
        
        [self setItems:@[two] animated:YES];
    }
    
}

- (void)commit {
    self.translucent = NO;
    self.barTintColor = [UIColor hex:0x333333 alpha:1];
    self.alpha = 0.6;
    self.tintColor = [UIColor hex:0xcccccc alpha:1];
}

@end
