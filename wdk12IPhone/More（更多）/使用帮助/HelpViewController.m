//
//  HelpViewController.m
//  wdk12IPhone
//
//  Created by wangdi on 16/6/6.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"jsbzzx.htm" withExtension:nil];
    NSURLRequest * request = [NSURLRequest requestWithURL:fileURL];
    [self.myWebView loadRequest:request];
    
    self.title = NSLocalizedString(@"使用帮助", nil);
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    
    
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    [self.imageView zk_AlignInner:(ZK_AlignTypeTopLeft) referView:self.view size:(CGSizeMake([UIScreen mainScreen].bounds.size.width, 64)) offset:(CGPointMake(0, 0))];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([UIScreen mainScreen].bounds.size.width, 64), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.view.window.layer renderInContext:ctx];
    UIImage *imgScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = imgScreen;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
