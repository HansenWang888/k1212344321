//
//  HWClassesChoiceItem.h
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/25.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWClassesChoiceItem : UIView
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;

+ (instancetype)choiceItemView;
@end
