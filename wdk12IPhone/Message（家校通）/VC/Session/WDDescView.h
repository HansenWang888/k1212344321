//
//  WDDescView.h
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/25.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AvatarImageView;
@interface WDDescView : UIView
@property (weak, nonatomic) IBOutlet AvatarImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *autographLabel;//个性签名
+ (instancetype)descView;
@end
