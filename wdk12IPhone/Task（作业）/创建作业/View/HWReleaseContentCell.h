//
//  HWReleaseContentCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/14.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

///  发布内容cell
@interface HWReleaseContentCell : UITableViewCell

@property (nonatomic, weak) UIViewController *superViewController;
///  作业名称textField
@property (nonatomic, strong) UITextField *nameTextField;

- (NSDictionary *)releaseTaskAction;

@end
