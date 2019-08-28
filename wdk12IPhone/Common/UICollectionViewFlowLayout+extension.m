//
//  UICollectionViewFlowLayout+extension.m
//  wdk12pad-HD-T
//
//  Created by 王振坤 on 16/4/11.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "UICollectionViewFlowLayout+extension.h"

@implementation UICollectionViewFlowLayout (extension)

+ (UICollectionViewFlowLayout *)collectViewFlowLayoutWithLineSpacing:(CGFloat)lineSpacing InteritemSpacing:(CGFloat)interitemSpacing itemSize:(CGSize)itemSize scrollDirection:(UICollectionViewScrollDirection)srollDirection sectionInset:(UIEdgeInsets)edgeInset {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = interitemSpacing;
    layout.itemSize = itemSize;
    layout.scrollDirection = srollDirection;
    layout.sectionInset = edgeInset;
    return layout;
}

@end
