//
//  MessageTableView.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  ContactTableViewCellTouchedDelegate<NSObject>

@optional
-(void)UserTouched:(NSString* _Nonnull ) uid;
-(void)NewFriendTouched;
-(void)GroupTouched;
-(void)SubscribeTouched;
@end

@interface ContactTableView : UITableView<UITableViewDataSource ,UITableViewDelegate>

@property(nonatomic,weak,nullable) id<ContactTableViewCellTouchedDelegate> contactTableViewdelegate;

@end
