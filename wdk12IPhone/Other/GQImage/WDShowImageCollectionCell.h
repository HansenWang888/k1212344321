//
//  WDShowImageCollectionCell.h
//  是生死
//
//  Created by 官强 on 2017/8/17.
//  Copyright © 2017年 guanqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDShowImageCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageV;


- (void)setImageViewWithUrl:(NSString *)imageStr;

- (void)setCellWithImage:(UIImage *)image;


@end
