//
//  InteractionReplyViewController.m
//  wdk12IPhone
//
//  Created by cindy on 15/11/30.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "InteractionReplyViewController.h"
#import "WDHTTPManager.h"

@interface InteractionReplyViewController ()

@end

@implementation InteractionReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //textView的边框
    self.myTextView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.myTextView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.myTextView.layer.borderWidth = 1.0;
    self.myTextView.layer.cornerRadius = 4.0f;
    
    //确定btn的弧度
    self.commitBtn.layer.cornerRadius = 6;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击背景
- (IBAction)clickBg:(id)sender {
    [self.view removeFromSuperview];
    
}
//点击叉号
- (IBAction)clickCancel:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)clickOk:(id)sender {
    
    if (!self.myTextView.text || [self.myTextView.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"请输入回答内容"];
        return ;
    }
    
    
    
    NSLog(@"%@",self.info);
    [self requestSubmitReply];
}

#pragma mark requestData
//请求发送回复
-(void)requestSubmitReply
{
    WDTeacher * teacher = [WDTeacher sharedUser];
    NSDictionary * httpDic = @{@"wtID":self.wtId,
                           @"hdID":[self.info objectForKey:@"hdID"],
                           @"userID":teacher.teacherID,
                           @"hdwz":self.myTextView.text,
                           @"yhlx":teacher.userType};
    
    
    [SVProgressHUD showWithStatus:@""];
    [[WDHTTPManager sharedHTTPManeger]getMethodDataWithParameter:httpDic urlString:[NSString stringWithFormat:@"%@/wd!tjwthf.action",EDU_BASE_URL] finished:^(NSDictionary * dic) {
        
//        NSLog(@"%@",dic);
        if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"true"]) {
            [self.view removeFromSuperview];
            
            //发送成功消息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"replyOk" object:nil];
            
        }else{
            [SVProgressHUD showInfoWithStatus:@"回复失败！"];
        }
        [SVProgressHUD dismiss];
        
    }];
    

}
@end
