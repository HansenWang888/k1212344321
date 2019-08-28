//
//  HWPhotoCheckImageViewCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 2016/11/11.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWPhotoCheckImageViewCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController *superViewController;

- (void)setImageViewWithData:(NSString *)imageStr;

@end
