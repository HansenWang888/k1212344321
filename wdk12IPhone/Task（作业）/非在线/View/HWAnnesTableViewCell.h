//
//  HWAnnesTableViewCell.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/8/10.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWAccessoryModel;

///  附件cell
@interface HWAnnesTableViewCell : UITableViewCell

@property (nonatomic, copy) NSArray<HWAccessoryModel *> *dataSource;

@property (nonatomic, copy) void(^didSel)(NSIndexPath *index);

@end
