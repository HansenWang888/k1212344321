//
//  ChatRecordPromtView.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/8/29.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatRecordPromtView : UIView
@property (weak, nonatomic) IBOutlet UILabel *imageLable;
@property (weak, nonatomic) IBOutlet UILabel *label;

+ (instancetype)recordPromtView;
- (void)showView;
- (void)hiddenView;
@end
