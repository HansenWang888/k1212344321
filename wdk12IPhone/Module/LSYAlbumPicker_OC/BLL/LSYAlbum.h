//
//  LSYAlbum.h
//  AlbumPicker
//
//  Created by okwei on 15/7/23.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^albumGroupsBlock)(NSMutableArray *groups);
typedef void (^albumAssetsBlock)(NSMutableArray *assets);
@class IMPhotoModel;
@interface LSYAlbum : NSObject
@property (nonatomic,strong) ALAssetsGroup *assetsGroup;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,strong) ALAssetsFilter *assstsFilter;
@property (nonatomic,strong) NSMutableArray *groups;
@property (nonatomic,strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *savePhotoes;

+(LSYAlbum *)sharedAlbum;
-(void)setupAlbumGroups:(albumGroupsBlock)albumGroups;
-(void)setupAlbumAssets:(ALAssetsGroup *)group withAssets:(albumAssetsBlock)albumAssets;
- (void)photosWithFinished:(void(^)(NSArray<IMPhotoModel *> *))finished;
@end
