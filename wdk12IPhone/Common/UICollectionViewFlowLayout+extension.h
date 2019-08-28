//
//  UICollectionViewFlowLayout+extension.h
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/11.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewFlowLayout (extension)

+ (UICollectionViewFlowLayout *)collectViewFlowLayoutWithLineSpacing:(CGFloat)lineSpacing InteritemSpacing:(CGFloat)interitemSpacing itemSize:(CGSize)itemSize scrollDirection:(UICollectionViewScrollDirection)srollDirection sectionInset:(UIEdgeInsets)edgeInset;

@end
