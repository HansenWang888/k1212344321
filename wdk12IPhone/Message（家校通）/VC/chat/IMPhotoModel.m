//
//  IMPhotoModel.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "IMPhotoModel.h"
#import "LSYAlbum.h"
@interface IMPhotoModel ()


@end
@implementation IMPhotoModel

- (instancetype)initWithAsset:(ALAsset *)asset {
    if (self = [super init]) {
        _asset = asset;
        _image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
//        _originalImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
    }
    return self;
}

- (UIImage *)scaleImageWithImage:(UIImage *)img height:(CGFloat)h {
    
    CGFloat width = h / img.size.height * img.size.width;
    CGRect rect = CGRectMake(0, 0, width, h);
    UIGraphicsBeginImageContext(CGSizeMake(width, h));
    [img drawInRect:rect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
@end
