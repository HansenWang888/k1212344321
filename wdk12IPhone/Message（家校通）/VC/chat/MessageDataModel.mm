#import "MessageDataModel.h"


#import "DDDatabaseUtil.h"
#import "ChatMarcos.h"
#import "SessionEntity.h"
#import "DDMessageEntity.h"
#import "MessageSendModule.h"
#include <map>
#import "PlayerManager.h"
#import "SessionModule.h"
#define TIME_DIM 300

typedef enum {
    SitOrderNormal,
    SitOrderReverse
}SitOrder;

typedef std::map<NSInteger,CGSize> MessageSizeMap;

@implementation MessageDataModel
{
    NSInteger _initialMessageCount;
    NSInteger _pullMessageCount;
    NSString* _sid;
    SessionEntity* _sentity;
    UITableView* _tableView;
    //auto sorted by timeinterval
    NSMutableArray<DDMessageEntity*>* _messages;
    
    NSMutableIndexSet*   _msgIDs;
    
    MessageSizeMap    _messageSizes;
    
    NSMutableArray* _textCells;
    
    NSTimeInterval _earlistMessageTime;
    
    DDMessageEntity* _latestMessage;
    DDMessageEntity* _earlistMessage;
    
    NSInteger _pureMessageCount;
    
    BOOL _canPulling;
    
    BOOL _voiceIng;
    BOOL _autoBottom;
}
-(id)initWithSession:(SessionEntity*)sentity TableView:(UITableView*)tableView InitialMessageCount:(NSInteger)initialMessageCount PullMessageCount:(NSInteger)pullMessageCount{
    self = [super init];
    
    
    _sid = sentity.sessionID;
    _sentity = sentity;
    _earlistMessageTime = sentity.timeInterval;
    _pullMessageCount = pullMessageCount;
    _initialMessageCount = initialMessageCount;
    _messages = [NSMutableArray new];
    
    _tableView = tableView;
    
    _msgIDs = [NSMutableIndexSet new];
    
    _canPulling = YES;
    _autoBottom = YES;
    
    _voiceIng = NO;
    [self pullingMessageWithAnimate:NO Block:^{
        if(_messages.count>0){
            [_tableView reloadData];
            [self ScrollToBottomWithAnimate:NO];
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReciveMessage:) name:DDNotificationReceiveMessage object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onResendMessage:) name:DDNotificationResendMessage object:nil];
    }];
    
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [[PlayerManager sharedManager]stopPlaying];
}

-(void)onReciveMessage:(NSNotification*)notify{
    
    DDMessageEntity* msg = [notify.object objectAtIndex:0];
    
    assert(msg);
    if(![msg.sessionId isEqualToString:_sid]) return;
    
    //some thing error
    if([_msgIDs containsIndex:msg.msgID]) return;
    
    NSInteger sit = [self reversegetMessageSit:msg];
    if(sit < 0) return;
    
    if(_autoBottom == YES){
        [self insertNewMessage:msg];
    }
    else{
        [self insertMessage:msg Animate:YES SitOrder:SitOrderReverse];
    }
    if (_tableView) {
        [[SessionModule sharedInstance] setSessionRead:_sentity];
    }
}
-(void)onResendMessage:(NSNotification*)notify{
    
    DDMessageEntity* msgentity = notify.object;
    if(![_messages containsObject:msgentity]){
        return;
    }
    NSInteger oldindex = [_messages indexOfObject:msgentity];
    msgentity.msgTime = [[NSDate date] timeIntervalSince1970];
    msgentity.state = DDMessageSending;
    [_messages removeObject:msgentity];
    NSInteger newindex = [self reversegetMessageSit:msgentity];
    [_messages insertObject:msgentity atIndex:newindex];
    if(oldindex == newindex){
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newindex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else{
        [_tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:oldindex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newindex inSection:0]];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newindex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self ScrollToBottomWithAnimate:YES];
    }
    [[MessageSendModule shareInstance]resendMessage:msgentity Session:_sentity];
}
-(void)pullingMessageWithAnimate:(BOOL)animate Block:(PullMessageCompetion)block{
    
    
    [[DDDatabaseUtil instance]loadMessageForSessionID:_sentity.sessionID pageCount:_pullMessageCount index:_pureMessageCount completion:^(NSArray<DDMessageEntity*> *array, NSError *error) {
        
        if(error||array.count == 0 ) {
            _canPulling = NO;
            block();
            return ;
        }
        
        [array enumerateObjectsUsingBlock:^(DDMessageEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.state == DDMessageSending && ![[MessageSendModule shareInstance]isInSendingQueue:obj]){
                obj.state = DDMessageSendFailure;
                
                [[DDDatabaseUtil instance]insertMessages:@[obj] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
            }
            [self insertMessage:obj Animate:animate SitOrder:SitOrderNormal];
            
        }];
        
        if(array.count>0){
            DDTimeDimMessageEntity* timedim = [[DDTimeDimMessageEntity alloc]initWithTimeInterval:_messages[0].msgTime];
            [_messages insertObject:timedim atIndex:0];
            if(animate){
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [_tableView endUpdates];
            }
        }
        if(array.count < _initialMessageCount) _canPulling = NO;
        block();
    }];
}

-(void)pullMessage:(PullMessageWithTotalHeight)block{
    
    NSInteger oldcount = _messages.count;
    [self pullingMessageWithAnimate:YES Block:^{
        NSInteger newcount = _messages.count;
        
        NSInteger dim = newcount - oldcount;
        CGFloat height = 0;
        for(NSInteger i = 0 ; i < dim ;++i){
            height += [self SizeForMessageAtIndex:i].height;
        }
        
        block(height,dim);
    }];
}
-(void)setAutoToButton:(BOOL)enable{
    _autoBottom = enable;
}
-(BOOL)canPulling{
    return _canPulling;
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
    if(msgentity.msgContentType == DDMessageTypeInvite) return CGSizeMake(200,110);
    if (msgentity.msgContentType == DDMessageTypeShare) {
        return CGSizeMake(200, 140);
    }
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


//反向便利，因为更新的基本都是靠后的消息
-(NSInteger)reverseSearchMsgByID:(NSInteger)msgid{
    __block NSInteger ret = -1;
    [_messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DDMessageEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.msgID == msgid){
            *stop = YES;
            ret = idx;
        }
    }];
    
    return  ret;
}

-(NSInteger)getMessageSit:(DDMessageEntity*)msgentity{
    for(NSInteger i = 0 ; i < _messages.count ; ++i){
        DDMessageEntity* exist = _messages[i];
        if(msgentity.msgTime<exist.msgTime){
            return i;
        }
        if(msgentity.msgTime == exist.msgTime&&msgentity.msgID<exist.msgID){
            return i;
        }
        continue;
    }
    
    return 0;
}
-(NSInteger)reversegetMessageSit:(DDMessageEntity*)msgentity{
    
    for(NSInteger i = _messages.count-1 ; i >=0 ; --i){
        DDMessageEntity* exist = _messages[i];
        if(msgentity.msgTime> exist.msgTime ){
            return i+1;
        }
        if(msgentity.msgTime == exist.msgTime && msgentity.msgID>exist.msgID){
            return i+1;
        }
        continue;
    }
    
    return 0;
}
-(void)insertMessage:(DDMessageEntity*)msgentity Animate:(BOOL)animate {
    [self insertMessage:msgentity Animate:animate SitOrder:SitOrderReverse];
}
-(void)insertMessage:(DDMessageEntity*)msgentity Animate:(BOOL)animate SitOrder:(SitOrder)sitorder{
    if([_msgIDs containsIndex:msgentity.msgID]) return;
    NSInteger sit = 0;
    if(sitorder == SitOrderNormal) sit = [self getMessageSit:msgentity];
    else if(sitorder == SitOrderReverse) sit = [self reversegetMessageSit:msgentity];
    else assert(0);
    
    //判断sit看看是否要丢事件,和前一个以及后一个比较时间
    
    //后面的消息插入时间
    if(sit< _messages.count && ![_messages[sit] isKindOfClass:[DDTimeDimMessageEntity class]] ){
        DDMessageEntity* after = _messages[sit];
        
        if(after.msgTime - msgentity.msgTime > TIME_DIM){
            DDMessageEntity* timedim = [[DDTimeDimMessageEntity alloc]initWithTimeInterval:after.msgTime];
            
            [_messages insertObject:timedim atIndex:sit];
            if(animate){
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sit inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [_tableView endUpdates];
            }
        }
    }
    if(sit-1<_messages.count && sit-1>=0 && ![_messages[sit-1] isKindOfClass:[DDTimeDimMessageEntity class]] ){
        
        DDMessageEntity* before = _messages[sit-1];
        if(msgentity.msgTime - before.msgTime > TIME_DIM){
            DDMessageEntity* timedim = [[DDTimeDimMessageEntity alloc]initWithTimeInterval:msgentity.msgTime];
            [_messages insertObject:timedim atIndex:sit];
            if(animate){
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sit inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [_tableView endUpdates];
            }
            sit = sit+1;
        }
    }
    
    //三句最重要的话
    
    [_messages insertObject:msgentity atIndex:sit];
    if(msgentity.msgID >0){
        [_msgIDs addIndex:msgentity.msgID];
        _pureMessageCount++;
    }
    
    if(animate){
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sit inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }
    
    
    
}

-(void)insertNewMessage:(DDMessageEntity*)msgentity{
    [self insertMessage:msgentity Animate:YES];
    
    [self ScrollToBottomWithAnimate:YES];
    
}


-(void)ScrollToBottomWithAnimate:(BOOL)animate{
    if(_messages.count>0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
        _autoBottom = YES;
    }
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
    if (entity.msgContentType == DDMessageTypeShare) return @"Share";
    return @"Other";
}
-(NSString*)chatPostfixWithIndex:(NSInteger)index{
    DDMessageEntity* entity = _messages[index];
    if(_sentity.sessionType == SessionTypeSessionTypeSubscription && entity.msgContentType == DDMessageTypeRichText) return @"center";
    if(entity.senderId && [entity.senderId isEqualToString:TheRuntime.user.objID]){
        return @"right";
    }
    if(entity.senderId && ![entity.senderId isEqualToString:TheRuntime.user.objID]){
        return @"left";
    }
    return @"center";
}
-(BOOL)isVoicing{
    return _voiceIng;
}
-(void)addBlinkAudioPlacehoder{
    // if(_voiceIng)return;
    assert(_voiceIng == NO);
    
    DDMessageEntity* msg = [[DDMessageEntity alloc]init];
    msg.msgID = VOICE_PLACEHODER;
    msg.msgTime = [NSDate date].timeIntervalSince1970;
    msg.senderId = TheRuntime.user.objID;
    msg.sessionId = _sid;
    msg.msgContentType = DDMessageTypeVoice;
    [self insertNewMessage:msg];
    _voiceIng = YES;
}
-(NSInteger)findVoicePlaceHolder{
    for(NSInteger i = _messages.count-1 ; i >=0 ; --i){
        DDMessageEntity* exist = _messages[i];
        if(exist.msgID == VOICE_PLACEHODER) return i;
    }
    assert(0);
    return -1;
}
-(void)UpdateOrReplaceVoiceMessage:(DDMessageEntity*)msgentity{
    assert(_voiceIng == YES);
    NSInteger placeholdersit = [self findVoicePlaceHolder];
    
    if(!msgentity){
        [_messages removeObjectAtIndex:placeholdersit];
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:placeholdersit inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }
    else{
        NSInteger newsit = [self reversegetMessageSit:msgentity];
        
        if(newsit == placeholdersit+1){
            [_messages replaceObjectAtIndex:placeholdersit withObject:msgentity];
            [_tableView beginUpdates];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:placeholdersit inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView endUpdates];
        }
        else{
            [_messages removeObjectAtIndex:placeholdersit];
            newsit = [self reversegetMessageSit:msgentity];
            [_messages insertObject:msgentity atIndex:newsit];
            [_tableView beginUpdates];
            [_tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:placeholdersit inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newsit inSection:0]];
            [_tableView endUpdates];
            [_tableView beginUpdates];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newsit inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView endUpdates];
            
            
        }
    }
    [self ScrollToBottomWithAnimate:YES];
    _voiceIng = NO;
}
@end
