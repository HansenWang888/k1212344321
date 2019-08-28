//
//  HWDataCollectionViewCell.h
//  wdk12IPhone
//
//  Created by 王振坤 on 16/8/12.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTaskPreviewData;

///  附件collectionView
@interface HWDataCollectionViewCell : UICollectionViewCell

- (void)setValueForDataSource:(HWTaskPreviewData *)data;

@end
