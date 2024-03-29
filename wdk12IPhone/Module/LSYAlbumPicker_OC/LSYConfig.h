//
//  LSYConfig.h
//  AlbumPicker
//
//  Created by okwei on 15/7/24.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

#ifndef AlbumPicker_LSYConfig_h
#define AlbumPicker_LSYConfig_h
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LSYAlbum.h"
static NSString * const kAlbumCellIdentifer = @"albumCellIdentifer";
static NSString * const kAlbumCatalogCellIdentifer = @"albumCatalogCellIdentifer";
#define ScreenSize [UIScreen mainScreen].bounds.size
#define kThumbnailLength    ([UIScreen mainScreen].bounds.size.width - 5*5)/4
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)
#define DistanceFromTopGuiden(view) (view.frame.origin.y + view.frame.size.height)
#define DistanceFromLeftGuiden(view) (view.frame.origin.x + view.frame.size.width)
#define ViewOrigin(view)   (view.frame.origin)
#define ViewSize(view)  (view.frame.size)
#endif
