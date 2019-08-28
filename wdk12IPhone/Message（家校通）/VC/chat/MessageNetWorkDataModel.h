//
//  MessageNetWorkDataModel.h
//  wdk12pad-HD-T
//
//  Created by macapp on 16/4/9.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^PullMessageCompetion)(BOOL);
typedef void(^PullMessageWithTotalHeight)(CGFloat,NSInteger);
@class DDMessageEntity;
@class SessionEntity;
@interface MessageNetWorkDataModel : NSObject
-(id)initWithSubscribeID:(NSString*)sbid TableView:(UITableView*)tableView InitialMessageCount:(NSInteger)initialMessageCount PullMessageCount:(NSInteger)pullMessageCount;




-(NSInteger)count;
-(DDMessageEntity*)messageAtInde:(NSInteger)index;
-(CGSize)SizeForMessageAtIndex:(NSInteger)index;

-(NSString*)chatPostfixWithIndex:(NSInteger)index;
-(NSString*)chatPrefixWithIndex:(NSInteger)index;

-(void)pullMessage:(BOOL)autoInsert Block:(PullMessageCompetion)block;
@end
