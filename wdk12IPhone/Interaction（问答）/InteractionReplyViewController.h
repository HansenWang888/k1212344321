//
//  InteractionReplyViewController.h
//  wdk12IPhone
//
//  Created by cindy on 15/11/30.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InteractionReplyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (nonatomic,strong) NSDictionary * info;
@property (nonatomic,copy) NSString * wtId; //问题ID

@end
