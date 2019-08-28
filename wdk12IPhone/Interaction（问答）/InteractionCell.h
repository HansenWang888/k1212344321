//
//  InteractionCell.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InteractionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headPortrait;
@property (weak, nonatomic) IBOutlet UILabel *myTitle;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *myTime;
@property (weak, nonatomic) IBOutlet UILabel *myDescribe;
@property (weak, nonatomic) IBOutlet UILabel *myType;
@property (weak, nonatomic) IBOutlet UILabel *answerNum;

+ (instancetype)interactionCell;

@end
