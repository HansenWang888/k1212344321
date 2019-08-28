//
//  DateTableViewCell.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTableViewCell : UITableViewCell
//天数
@property (nonatomic, assign) NSInteger days;
//weekday
@property (nonatomic, copy) NSString *weekday;
//标题日期
@property (nonatomic, strong) NSArray *titleCompoents;

@property (weak, nonatomic) IBOutlet UILabel *upDate;

+ (instancetype)dateTableViewCell;
@end
