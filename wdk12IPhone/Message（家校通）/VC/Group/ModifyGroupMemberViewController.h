//
//  MessageViewController.h
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "avatarImageView.h"

//失败的类，只能加，忘了群组删人了我操
@class  SessionEntity;
@class  GroupEntity;
@interface ModifyGroupMemberViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate>

//-(id)initWithGroupID:(NSString* )gid;
-(id)initWithSession:(SessionEntity*)sentity;
@end

//Kakashi
@interface DelGroupMemberViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate>
-(id)initWithGroup:(GroupEntity*)gentity;
@end