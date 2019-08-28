//
//  ScheduleTableViewCell.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/21.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "ScheduleTableViewCell.h"
#import "WDCourseList.h"

@interface ScheduleTableViewCell ()

///  第几节课
@property (nonatomic, strong) UILabel *coursesLabel;
///  开课时间
@property (nonatomic, strong) UILabel *coursesTimeLabel;
///  科目
@property (nonatomic, strong) UILabel *subjectLabel;
///  上课教师
@property (nonatomic, strong) UILabel *teacherLabel;
///  科目教师后的背景view
@property (nonatomic, strong) UIView *backView;

@end

@implementation ScheduleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [self initAutoLayout];
    }
    return self;
}

- (void)initView {
    self.coursesLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x298A6D alpha:1.0] font:[UIFont systemFontOfSize:18] alpha:1.0];
    self.coursesTimeLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor hex:0x298A6D alpha:1.0] font:[UIFont systemFontOfSize:12] alpha:1.0];
    self.subjectLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12] alpha:1.0];
    self.teacherLabel = [UILabel labelBackgroundColor:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12] alpha:1.0];
    self.backView = [UIView viewWithBackground:[UIColor hex:0x298A6D alpha:1.0] alpha:1.0];
    
    [self.contentView addSubview:self.coursesLabel];
    [self.contentView addSubview:self.coursesTimeLabel];
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.subjectLabel];
    [self.backView addSubview:self.teacherLabel];
}

- (void)initAutoLayout {
    [self.coursesLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.contentView size:CGSizeZero offset:CGPointMake(10, 10)];
    [self.coursesTimeLabel zk_AlignVertical:ZK_AlignTypeBottomLeft referView:self.coursesLabel size:CGSizeZero offset:CGPointMake(0, 10)];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.coursesLabel.mas_right).offset(10);
        make.top.offset(10);
        make.bottom.right.offset(-10);
    }];
    [self.subjectLabel zk_AlignInner:ZK_AlignTypeTopLeft referView:self.backView size:CGSizeZero offset:CGPointZero];
    [self.teacherLabel zk_AlignInner:ZK_AlignTypeBottomLeft referView:self.backView size:CGSizeZero offset:CGPointZero];
}

- (void)setValueForDataSource:(WDCourseList *)data isMySchedule:(BOOL)isMySchedule {
    self.coursesLabel.text = data.courseContent;
    self.coursesTimeLabel.text = data.courseTime;
    self.subjectLabel.text = data.subject;
    self.teacherLabel.text = !isMySchedule ? data.teacherName : data.classesName;
    
    if ([data.subject isEqualToString:@""] || data.subject == nil) {
        self.backView.alpha = 0.0;
    } else {
        self.backView.alpha = 1.0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

@end
