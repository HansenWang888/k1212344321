//
//  AnalysisTableViewCell.h
//  wdk12pad
//
//  Created by 王振坤 on 16/7/25.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

///  解析cell
@interface HomeworkOtherAnalysisCell : UITableViewCell

///  解析label
@property (nonatomic, strong) UILabel *analysisLabel;
///  解析内容label
@property (nonatomic, strong) UILabel *analysisContentLabel;

- (void)setValueForDataSource:(NSString *)data;

@end
