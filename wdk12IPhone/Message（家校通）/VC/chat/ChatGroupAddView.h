//
//  ChatGroupAddView.h
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/3/25.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatGroupAddDelegate <NSObject>

- (void)chatGroupAddUserWithVC:(UIViewController *)vc;
- (void)chatGroupDeleUserWithVC:(UIViewController *)vc;
- (void)chatGroupInfoUserWithVC:(UIViewController *)vc;

@end
@class SessionEntity;
@interface ChatGroupAddView : UICollectionView
@property (nonatomic, strong) SessionEntity *sentity;
@property (assign, nonatomic) id<ChatGroupAddDelegate> addDelegate;

@end
