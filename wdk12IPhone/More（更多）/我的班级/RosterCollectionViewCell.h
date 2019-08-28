//
//  RosterCollectionViewCell.h
//  wdk12IPhone
//
//  Created by cindy on 15/10/20.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StudentModel;

@interface RosterCollectionViewCell : UICollectionViewCell

- (void)setValueForDataSource:(StudentModel *)data;

@end
