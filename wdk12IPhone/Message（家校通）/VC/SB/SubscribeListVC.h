//
//  SubscribeListVC.h
//  wdk12pad
//
//  Created by macapp on 16/1/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AvatarImageView;
@class NameLabel;
@interface SubscribeListVC : UITableViewController

@end

@interface SBInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet NameLabel *naleLabel;

@end

