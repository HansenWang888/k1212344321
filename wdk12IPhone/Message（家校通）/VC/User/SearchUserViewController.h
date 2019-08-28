//
//  MessageViewController.h
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchUserDeleagte <NSObject>

- (void)searchUserCelldidSelectedForVC:(UIViewController *)vc;

@end
@interface SearchUserViewController : UIViewController
@property (assign, nonatomic) BOOL isSearchSubscribe;//搜索公众号
@property (assign, nonatomic) id<SearchUserDeleagte> searchDelegate;

@end
