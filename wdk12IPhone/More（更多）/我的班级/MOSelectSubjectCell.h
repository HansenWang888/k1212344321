//
//  MOSelectSubjectCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/30.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWSubject;

///  更多模块选择科目cell
@interface MOSelectSubjectCell : UITableViewCell

@property (nonatomic, copy) NSArray<HWSubject *> *data;

@property (nonatomic, strong) UICollectionView *collectionView;

///  获取需要添加的科目id数据
- (NSMutableString *)getNeedAddSubjectIdData;

@end
