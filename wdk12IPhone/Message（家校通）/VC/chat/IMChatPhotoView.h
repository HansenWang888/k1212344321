//
//  IMChatPhotoView.h
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMPhotoModel;


@protocol ChatPhotoViewDelegate <NSObject>

@required
-(void)showAlbum:(id)sender;
-(void)showCamera:(id)sender;
-(void)disSelectedPhotos:(NSArray<IMPhotoModel *>*)photoes;
@end


@interface IMChatPhotoView : UIView

@property (nonatomic,weak,nullable)  id<ChatPhotoViewDelegate> delegate;
+ (instancetype)chatPhotoView;
@end

