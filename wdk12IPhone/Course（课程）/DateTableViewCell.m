//
//  DateTableViewCell.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "DateTableViewCell.h"

@interface DateTableViewCell ()


@property (weak, nonatomic) IBOutlet UILabel *downDay;

@end

@implementation DateTableViewCell

+ (instancetype)dateTableViewCell{

    return [[[NSBundle mainBundle] loadNibNamed:@"DateTableViewCell" owner:nil options:nil] lastObject];
}
//设置日期
- (void)setDays:(NSInteger)days {
    _days = days;
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                               NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate
                                                                                  date]];
    if (days == today.day && today.month == [self.titleCompoents[1] intValue] && today.year == [self.titleCompoents[0] intValue]) {
        self.upDate.text = NSLocalizedString(@"今天", nil);
        return;
    }
    self.upDate.text = [NSString stringWithFormat:@"%02ld",(long)days];
}
- (void)setWeekday:(NSString *)weekday {
    
    self.downDay.text = NSLocalizedString(weekday, nil);
}

//- (void)awakeFromNib {
//    // Initialization code
//}
////显示出的cell的选中状态
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
////    NSLog(@"选择了日期%d",selected);
//
//    // Configure the view for the selected state
//}
//
@end
