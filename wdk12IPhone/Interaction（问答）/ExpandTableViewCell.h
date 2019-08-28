//
//  ExpandTableViewCell.h
//  wdk12IPhone
//
//  Created by cindy on 15/10/30.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *headPortrait;
@property (weak, nonatomic) IBOutlet UILabel *myTitle;
@property (weak, nonatomic) IBOutlet UILabel *myTime;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *myDescribe;
@property (weak, nonatomic) IBOutlet UILabel *myType;

@property (weak, nonatomic) IBOutlet UIImageView *expandHeadPortrait;
@property (weak, nonatomic) IBOutlet UILabel *expandName;
@property (weak, nonatomic) IBOutlet UILabel *isAccept;
@property (weak, nonatomic) IBOutlet UITextView *expandTextView;
@property (weak, nonatomic) IBOutlet UILabel *expandTime;

@property (weak, nonatomic) IBOutlet UILabel *answerNum;

+ (instancetype)interactionCell;
@end
