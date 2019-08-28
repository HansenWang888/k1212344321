//
//  MyClassTableViewCell.h
//  Wd_Setting
//
//  Created by cindy on 15/10/16.
//  Copyright © 2015年 wd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassModel;

@interface MyClassTableViewCell : UITableViewCell

///  角色及任课教师label
@property (nonatomic, strong) UILabel *roleLabel;

- (void)setValueForDataSource:(ClassModel *)data;

@end
