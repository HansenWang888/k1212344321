#import "sessionCell.h"
#import "SessionModule.h"
#import "SessionEntity.h"
#import "DDUserModule.h"
#import "UIImageView+WebCache.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "ContactModule.h"
#import "contactinfo.h"
#import "DDGroupModule.h"
#import "NSDate+DDAddition.h"
#import "ViewSetUniversal.h"
#import <masonry.h>
#import "DDDatabaseUtil.h"
@interface SessionCell ()


@end
@implementation SessionCell
{
    SessionEntity* _sentity;
}
-(void)awakeFromNib{
    _unreadCountLabel.layer.cornerRadius = 8;
    _unreadCountLabel.layer.masksToBounds = YES;
    _distrubImabeView.tintColor = [UIColor lightGrayColor];
//    self.backgroundColor = [UIColor clearColor];
//    UIView *vv = [UIView new];
//    vv.backgroundColor = [UIColor clearColor];
//    vv.bounds = self.frame;
//    UIView *selectedV = [[UIView alloc] init];
//    selectedV.backgroundColor =  COLOR_Creat(67, 79, 90, 1);
//    [vv addSubview:selectedV];
//    [selectedV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(vv).offset(8);
//        make.right.equalTo(vv).offset(-8);
//        make.top.bottom.equalTo(vv);
//    }];
//    [ViewSetUniversal setView:selectedV cornerRadius:5];
//    self.selectedBackgroundView = vv;
}

- (void)settelSubscribes {
    NSInteger unredadCount;
    NSString *messageStr;
    NSTimeInterval lastTime;
    self.avatarImageView.image = [UIImage imageNamed:@"SB-H"];
    [[SessionModule sharedInstance] getSubscribeUnread:&unredadCount LastMessage:&messageStr LastTime:&lastTime];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:lastTime];
    self.unreadCountLabel.text = [NSString stringWithFormat:@"%tu",unredadCount];
    self.latestSessionMessageLabel.text = messageStr;
    _latestSessionTimeLabel.text = lastTime >0?[date promptDateString]:@"";
    if(unredadCount == 0){
        [_unreadCountLabel setHidden:YES];
    }
    else{
        [_unreadCountLabel setHidden:NO];
        if(unredadCount >99){
            _unreadCountLabel.text = [NSString stringWithFormat:@"%ld",unredadCount];
        }
        else{
            _unreadCountLabel.text = [NSString stringWithFormat:@"%ld",unredadCount];
        }
    }
}
-(SessionEntity*)sessionEntity{
    return _sentity;
}
-(void)setSessionEntity:(SessionEntity*)sentity{
    _sentity = sentity;
    
    _latestSessionMessageLabel.text = sentity.lastMsg;

    NSDate* date = [[NSDate alloc]initWithTimeIntervalSince1970:sentity.timeInterval];
    _latestSessionTimeLabel.text = sentity.timeInterval >0?[date promptDateString]:@"";
    if(sentity.unReadMsgCount == 0){
        [_unreadCountLabel setHidden:YES];
    }
    else{
        [_unreadCountLabel setHidden:NO];
        if(sentity.unReadMsgCount >99){
            _unreadCountLabel.text = [NSString stringWithFormat:@"%ld",sentity.unReadMsgCount];
        }
        else{
            _unreadCountLabel.text = [NSString stringWithFormat:@"%ld",sentity.unReadMsgCount];
        }
    }
    _distrubImabeView.hidden = (sentity.isShield == 0);
    
    if(sentity.topLevel !=0 ){
        
        self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.sessionNameLabel.textColor = [UIColor blackColor];
        _distrubImabeView.tintColor = [UIColor lightGrayColor];
    }
    else{
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    if(sentity.sessionType == SessionTypeSessionTypeSingle){
        [self UserUpdated:sentity.sessionID];
        [[ContactModule shareInstance]getUserInfoWithNotification:sentity.sessionID ForUpdate:NO];
    }
    if(sentity.sessionType == SessionTypeSessionTypeGroup){
        [self GroupUpdated:sentity.sessionID];
        [[DDGroupModule instance]getGroupInfoFromServerWithNotify:sentity.sessionID Forupdate:NO];
        //获取并显示最后一个发消息人的名称
        [[DDDatabaseUtil instance] getLastestMessageForSessionID:sentity.sessionID completion:^(DDMessageEntity *message, NSError *error) {
            if(message == nil){
                return ;
            };
            NSString *nick = @"";
            
            GroupEntity *gentity = [[DDGroupModule instance] getGroupByGId:sentity.sessionID];
            if(gentity){
                nick = [gentity getGroupNick:message.senderId];
            }
            if([nick isEqualToString:@""] || nick == nil){
                DDUserEntity* uentity = [[DDUserModule shareInstance]getUserByID:message.senderId];
                if(uentity) nick = uentity.nick;
            }
            if([nick isEqualToString:@""] || nick == nil){
                nick = message.senderId;
            }
            _latestSessionMessageLabel.text = [NSString stringWithFormat:@"%@:%@",nick,sentity.lastMsg];
        }];
    }
    if(sentity.sessionType == SessionTypeSessionTypeSubscription){
        
        [self subscribeUpdated:sentity.sessionID];
    }
    
}
-(void)UserUpdated:(NSString*)uid{
    [_avatarImageView setUid:uid];
    [_sessionNameLabel setUid:uid];
    
}

-(void)GroupUpdated:(NSString*)gid{
    [_avatarImageView setGroupID:gid];
    [_sessionNameLabel setGid:gid];
}
-(void)subscribeUpdated:(NSString*)sbid{
    [_sessionNameLabel setSBID:sbid];
    [_avatarImageView setSBID:sbid];
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    _unreadCountLabel.backgroundColor = [UIColor redColor];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
