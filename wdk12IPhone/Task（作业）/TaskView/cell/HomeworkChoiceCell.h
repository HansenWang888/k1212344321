//
//  SelectionTableViewCell.h
//  wdk12pad
//
//  Created by 王振坤 on 16/7/23.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class ProblemOption;

///  选择题cell
@interface HomeworkChoiceCell : UITableViewCell

///  选项按钮
@property (nonatomic, strong) UIButton *serialNumButton;
///  内容label
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, assign) BOOL isSelect;

- (void)setValueForDataSource:(NSDictionary *)dict;// {"xxnr":"6","xxxh":"C"}

@end
