//
//  HBBackImageBoard.h
//  DemoAntiAliasing
//
//  Created  on 15/11/6.
//  Copyright © 2015年 HB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBDrawCommon.h"


@interface HBBackImageBoard : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end
