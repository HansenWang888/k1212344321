//
//  SecondDetailCell.h
//  wdk12IPhone
//
//  Created by cindy on 15/11/5.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondDetailCell : UITableViewCell
+ (instancetype)interactionCell;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *myTextView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end
