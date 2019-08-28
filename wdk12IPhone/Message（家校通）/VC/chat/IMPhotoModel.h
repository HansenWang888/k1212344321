//
//  IMPhotoModel.h
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMPhotoModel : NSObject
//只有照片
@property (nonatomic,strong,readonly) ALAsset *asset;
@property (nonatomic) BOOL isSelect;
@property (nonatomic, copy,readonly) UIImage *image;//宽高比图片

- (instancetype)initWithAsset:(ALAsset *)asset;

@end
