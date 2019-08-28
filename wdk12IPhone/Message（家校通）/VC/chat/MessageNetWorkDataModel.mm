//
//  MessageNetWorkDataModel.m
//  wdk12pad-HD-T
//
//  Created by macapp on 16/4/9.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "MessageNetWorkDataModel.h"
#import "SessionEntity.h"
#import "DDMessageEntity.h"
#import "ChatMarcos.h"
#import "SubscribeModule.h"
#include <map>
#define TIME_DIM 300
typedef std::map<NSInteger,CGSize> MessageSizeMap;
typedef enum {
    SitOrderNormal,
    SitOrderReverse
}SitOrder;
@implementation MessageNetWorkDataModel{
    NSInteger _initialMessageCount;
    NSInteger _pullMessageCount;
    
    UITableView* _tableView;
    NSString* _sbid;
    NSMutableArray<DDMessageEntity*>* _messages;
    NSMutableIndexSet* _msgIDs;
    MessageSizeMap _messageSizes;
    NSInteger _pureMessageCount;
    BOOL _canPulling;
}
-(id)initWithSubscribeID:(NSString*)sbid TableView:(UITableView*)tableView InitialMessageCount:(NSInteger)initialMessageCount PullMessageCount:(NSInteger)pullMessageCount{
    self = [super init];
    
    
    _sbid = sbid;
    
    _messages = [NSMutableArray new];
    
    _tableView = tableView;
    
    _msgIDs = [NSMutableIndexSet new];
    _initialMessageCount = initialMessageCount;
    _pullMessageCount = pullMessageCount;
    [self pullMessage:NO Block:^(BOOL) {
        [_tableView reloadData];
    }];
    
    return self;
}


-(NSInteger)count{
    return _messages.count;
}

-(DDMessageEntity*)messageAtInde:(NSInteger)index{
    assert(index<_messages.count);
    return _messages[index];
}
-(CGSize)SizeForMessageAtIndex:(NSInteger)index{
    assert(index<_messages.count);
    
    DDMessageEntity* msgentity = _messages[index];
    if(msgentity.msgContentType == DDMessageTypeVoice) return CGSizeMake(200, CONTENT_TOP_MAX_MARGIN+CONTENT_BOTTOM_MARGIN+40);
    if(msgentity.msgContentType == DDMessageTypeImage) return CGSizeMake(200, CONTENT_TOP_MAX_MARGIN+CONTENT_BOTTOM_MARGIN+140);
    if(msgentity.msgContentType == DDMessageTypeTimeDim) return CGSizeMake(200,32);
    if(msgentity.msgContentType == DDMessageTypeVideo) return CGSizeMake(200, 180);
    if(msgentity.msgContentType == DDMessageTypeDoc) return CGSizeMake(200, 180);
    if(msgentity.msgContentType == DDMessageTypeInvite) return CGSizeMake(200,100);
    MessageSizeMap::iterator iter = _messageSizes.find(_messages[index].msgID);
    
    if(iter != _messageSizes.end()) return iter->second;
    
    
    if(msgentity.msgContentType == DDMessageTypeText){
        CGSize retSize = [msgentity.msgContent boundingRectWithSize:CGSizeMake(TEXT_MAX_WIDTH-2*TEXT_MARGIN, 0)
                                                            options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:FONT_ATTRIBUTE
                                                            context:nil].size;
        
        
        
        retSize.width  = ceilf(retSize.width);
        
        retSize.height += (CONTENT_TOP_MAX_MARGIN+CONTENT_BOTTOM_MARGIN)+2.0*TEXT_MARGIN;
        retSize.width  += ANCHOR_MARGIN+2.0*TEXT_MARGIN;
        
        
        
        _messageSizes[msgentity.msgID] = retSize;
        return retSize;
    }
    if(msgentity.msgContentType == DDMessageTypeRichText) {
        NSArray* subAry = [msgentity.info objectForKey:@"twsc"];
        CGFloat textLabelWidth = _tableView.frame.size.width*0.7-RICH_TEXT_SUB_TEXT_LABEL_WIDTH_DIM;
        __block CGFloat height = 0;
        [subAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString* title = [obj objectForKey:@"title"];
            
            CGFloat  textHeight = [title boundingRectWithSize:CGSizeMake(textLabelWidth, 0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:FONT_ATTRIBUTE
                                                      context:nil].size.height;
            height += textHeight>RICH_TEXT_CELL_HEIGHT?textHeight:RICH_TEXT_CELL_HEIGHT;
        }];
        height += ( RICH_TEXT_HEADER_HEIGHT+ 15 +20);
        CGSize retSize = CGSizeMake(200, height);
        _messageSizes[msgentity.msgID] = retSize;
        return retSize;
    }
    //未知消息类型size
    CGSize retSize = [IMLocalizedString(@"未知消息类型", nil) boundingRectWithSize:CGSizeMake(TEXT_MAX_WIDTH-2*TEXT_MARGIN, 0)
                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:FONT_ATTRIBUTE
                                             context:nil].size;
    retSize.width  = ceilf(retSize.width);
    
    retSize.height += (CONTENT_TOP_MAX_MARGIN+CONTENT_BOTTOM_MARGIN)+2.0*TEXT_MARGIN;
    retSize.width  += ANCHOR_MARGIN+2.0*TEXT_MARGIN;
    
    
    
    _messageSizes[msgentity.msgID] = retSize;
    return retSize;
}
-(NSString*)chatPrefixWithIndex:(NSInteger)index{
    DDMessageEntity* entity = _messages[index];
    
    if(entity.msgContentType == DDMessageTypeText) return @"Text";
    if(entity.msgContentType == DDMessageTypeVoice) return @"Voice";
    if(entity.msgContentType == DDMessageTypeImage) return @"Image";
    if(entity.msgContentType == DDMessageTypeTimeDim) return @"Time";
    if(entity.msgContentType == DDMessageTypeRichText) return @"RichText";
    if(entity.msgContentType == DDMessageTypeDoc) return @"File";
    if(entity.msgContentType == DDMessageTypeVideo) return @"Video";
    if(entity.msgContentType == DDMessageTypeInvite) return @"Invite";
    return @"Other";
}
-(NSString*)chatPostfixWithIndex:(NSInteger)index{
    DDMessageEntity* entity = _messages[index];
    if(1 && entity.msgContentType == DDMessageTypeRichText) return @"center";
    if(entity.senderId && [entity.senderId isEqualToString:TheRuntime.user.objID]){
        return @"right";
    }
    if(entity.senderId && ![entity.senderId isEqualToString:TheRuntime.user.objID]){
        return @"left";
    }
    return @"center";
}
-(void)pullMessage:(BOOL)autoInsert Block:(PullMessageCompetion)block{
    NSInteger lastMsgID = 0;
    lastMsgID = [_messages lastObject]?[_messages lastObject].msgID:0;
    [[SubscribeModule shareInstance]pullHistoryMessage:_sbid LastMsgID:lastMsgID PullCnt:_initialMessageCount Block:^(NSArray *msgAry) {
        
        NSInteger oldCnt = _messages.count;
        [_messages addObjectsFromArray:msgAry];
        if(autoInsert){
            NSMutableArray* indexPaths = [NSMutableArray new];
            [msgAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:oldCnt+idx inSection:0];
                [indexPaths addObject:indexPath];
            }];
            [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if(msgAry.count<_initialMessageCount){
            block(NO);
        }
        else{
            block(YES);
        }
        
        
        
        
    }];
}

@end
