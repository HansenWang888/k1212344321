//
//  GqpFilingTableViewCell.h
//  wdk12pad
//
//  Created by 王振坤 on 16/7/23.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

///  填空题题干
@interface Homework02TextCell : UITableViewCell

///  内容label
//@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *textField;

///  序号label
@property (nonatomic, strong) UILabel *numLabel;

- (void)setValueForDataSource:(NSString *)data;

@end
