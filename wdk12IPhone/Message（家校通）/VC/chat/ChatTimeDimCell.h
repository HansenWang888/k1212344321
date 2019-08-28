//
//  ChatTimeDimCell.h
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  DDMessageEntity;
@class SessionEntity;

@interface ChatBaseCell : UITableViewCell

-(void)setContentSize:(CGSize)size;
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity;
-(void)setSessionEntity:(SessionEntity*)sentity;
-(void)setSessionID:(NSString*)sid;
-(void)willAppare;
-(void)willDisappare;
@end






@interface ChatTimeDimCell : ChatBaseCell

-(void)setMessageEntity:(DDMessageEntity*)msgentity;


@end
