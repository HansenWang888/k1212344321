//
//  ChatCell.m
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "ChatCell.h"
#import "avatarImageView.h"
#import "DDMessageEntity.h"
#import "ChatAnthorView.h"
#import "SessionEntity.h"
#import "nameLabel.h"
#import "ChatMarcos.h"
#import "UIImageView+WebCache.h"
NSString* const SubNotify_AvatarTap = @"SubNotify_AvatarTap";

@interface  ChatCell()

@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property ( weak, nonatomic) IBOutlet ChatAnthorView *anchorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorWidthCS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorHeightCS;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UIImageView *faildMark;
@property (weak, nonatomic) IBOutlet NameLabel *namelabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorTopCS;
@property (weak, nonatomic) IBOutlet UILabel *voiceLengthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gifView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gifHeightCS;

@end

typedef enum{
    CHAT_LEFT,
    CHAT_RIGHT
} Chat_Forwoard;
@implementation ChatCell{
    //    SessionEntity* _sentity;
    NSString* _sid;
    DDMessageEntity* _msgentity;
@protected
    Chat_Forwoard _cf;
}
-(void)dealloc{
    
}
- (void)onResend:(id)sender {
    
    if(_msgentity.state == DDMessageSendFailure){
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationResendMessage object:_msgentity];
    }
    
}
-(void)onAvatarTap:(id)sender{
    
    if(_avatarImageView.Uid&& ![_avatarImageView.Uid isEqualToString:TheRuntime.user.objID]){
        [[NSNotificationCenter defaultCenter]postNotificationName:SubNotify_AvatarTap object:_avatarImageView.Uid];
    }
}
-(void)willDisappare{
    
    [_anchorView onDisappera];
}
-(void)awakeFromNib{
    _cf = CHAT_LEFT;
    UIImage* image =  [[UIImage imageNamed:@"gantanhao"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_faildMark setImage:image];
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onResend:)];
    
    [_faildMark addGestureRecognizer:gesture];
    _faildMark.tintColor = [UIColor redColor];
    
    [self hideMark];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(messageUpdate:) name:DDNotificationMessageSendingStateChanged object:nil];
    
    UITapGestureRecognizer* avagesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onAvatarTap:)];
    [_avatarImageView addGestureRecognizer:avagesture];
    _avatarImageView.userInteractionEnabled = YES;
    
}
-(void)messageUpdate:(NSNotification*)notify{
    
    NSString* sessionid = [notify.object objectAtIndex:0];
    if(![sessionid isEqualToString:_sid]) return;
    DDMessageState state = (DDMessageState)[[notify.object objectAtIndex:1]integerValue];
    
    
    if(state == DDMessageSendFailure){
        NSInteger msgid  = [[notify.object objectAtIndex:2]integerValue];
        if(msgid == _msgentity.msgID) {
            [self hideMark];
            _faildMark.hidden = NO;
        }
    }
    else if(state == DDmessageSendSuccess){
        NSInteger oldmsgid = [[notify.object objectAtIndex:2]integerValue];
        NSInteger newmsgid = [[notify.object objectAtIndex:3]integerValue];
        
        if(oldmsgid == _msgentity.msgID || newmsgid == _msgentity.msgID){
            [self hideMark];
            [self showDetail];
        }
    }
}
-(void)showDetail{
    
}
-(void)hideNick:(BOOL)hide{
    if(hide){
        self.namelabel.hidden = YES;
        self.anchorTopCS.constant = 8;
    }
    else {
        self.anchorTopCS.constant = 25;
        self.namelabel.hidden = NO;
    }
}
-(void)hideMark{
    _faildMark.hidden = YES;
    [_indicatorView stopAnimating];
    _indicatorView.hidden = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{
    //if(_msgentity == msgentity) return NO;
    _msgentity = msgentity;
    
    if(_msgentity.sessionType == SessionTypeSessionTypeSubscription&&![msgentity.senderId isEqualToString:TheRuntime.user.objID]){
        [_avatarImageView setSBID:msgentity.senderId];
        
    }
    else{
        [_avatarImageView setUid:msgentity.senderId];
    }
    
    if(_msgentity.sessionType == SessionTypeSessionTypeGroup){
        [_namelabel setUid:msgentity.senderId WithGID:_sid];
    }
    else{
        if(_msgentity.sessionType == SessionTypeSessionTypeSubscription&&![msgentity.senderId isEqualToString:TheRuntime.user.objID]){
            [_namelabel setSBID:msgentity.senderId];
        }
        else{
            [_namelabel setUid:msgentity.senderId];
        }
    }
    
    [self hideMark];
    if(msgentity.state == DDMessageSending) {
        [_indicatorView startAnimating];
    }
    else if(msgentity.state == DDMessageSendFailure) {
        [_faildMark setHidden:NO];
    }
    
    return YES;
}
-(void)setContentSize:(CGSize)size{
    
}
-(void)setSessionEntity:(SessionEntity*)sentity{
    _sid = sentity.sessionID;
    if(_cf == CHAT_LEFT){
        [self hideNick:sentity.showNick==0];
    }
}
-(void)setSessionID:(NSString *)sid{
    _sid = sid;
    [self hideNick:NO];
}
@end










@implementation ChatTextCell

-(BOOL)setMessageEntity:(DDMessageEntity *)msgentity{
    BOOL ret = [super setMessageEntity:msgentity];
    if(ret){
        
        [self.anchorView setText:msgentity.msgContent];
    }
    return ret;
}
-(void)setContentSize:(CGSize)size{
    self.anchorWidthCS.constant = size.width;
    self.anchorHeightCS.constant = size.height-45;
    [self.anchorView layoutIfNeeded];
    [self.anchorView.layer removeAllAnimations];
}
@end

@implementation ChatTextCellRight

-(void)awakeFromNib{
    [super awakeFromNib];
    [self hideNick:YES];
    _cf = CHAT_RIGHT;
    
}

@end


@implementation ChatImageCell


-(void)awakeFromNib{
    [super awakeFromNib];
    
    //   self.anchorWidthCS.constant = 110;
    //   self.anchorHeightCS.constant = 140;
}
-(BOOL)setMessageEntity:(DDMessageEntity *)msgentity{
    BOOL ret = [super setMessageEntity:msgentity];
    if(ret){
        NSString* localUrl = [msgentity.info objectForKey:IMAGE_LOCAL_KEY];
        NSString* httpUrl = [msgentity.info objectForKey:IMAGE_HTTP_KEY];
        
        if(httpUrl && ([[httpUrl pathExtension] isEqualToString:@"gif"]||
                       [[httpUrl pathExtension] isEqualToString:@"GIF"])){
            self.anchorView.hidden = YES;
            self.gifView.hidden = NO;
            [self.gifView sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(httpUrl)] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                
            }];
        }
        else{
            self.anchorView.hidden = NO;
            self.gifView.hidden = YES;
            if(localUrl) {
                [self.anchorView setImageUrl:localUrl];
            }
            else if(httpUrl){
                [self.anchorView setImageUrl:ImageFullUrl(httpUrl)];
            }
            else{
                [self.anchorView setImageUrl:@""];
            }
        }
    }
    return ret;
}
@end

@implementation ChatImageRightCell

-(void)awakeFromNib{
    [super awakeFromNib];
    [self hideNick:YES];
    _cf = CHAT_RIGHT;
}

@end

@implementation ChatVoiceCell

-(void)showDetail{
    [super showDetail];
    self.voiceLengthLabel.hidden = NO;
}


-(BOOL)setMessageEntity:(DDMessageEntity *)msgentity{
    
    [super setMessageEntity:msgentity];
    
    NSString* localUrl = [msgentity.info objectForKey:VOICE_LOCAL_KEY];
    NSString* httpUrl = [msgentity.info objectForKey:VOICE_HTTP_KEY];
    NSTimeInterval length = [[msgentity.info objectForKey:VOICE_LENGTH_KEY]doubleValue];
    
    if(localUrl) {
        [self.anchorView setAudioAndLength:localUrl IsHttp:NO];
    }
    else if(httpUrl){
        [self.anchorView setAudioAndLength:ImageFullUrl(httpUrl) IsHttp:YES];
    }
    else{
        [self.anchorView setAudioAndLength:nil IsHttp:NO];
    }
    self.anchorWidthCS.constant = 80+MIN(length*10, 120);
    [self.anchorView.layer removeAllAnimations];
    
    
    NSInteger secs = length;
    NSString* timetext = [NSString stringWithFormat:@"%ld″",secs%60];
    NSInteger minus = (secs%3600)/60;
    if(minus > 0) timetext = [NSString stringWithFormat:@"%ld′ %@",minus,timetext];
    NSInteger hours = secs/3600;
    if(hours > 0) timetext = [NSString stringWithFormat:@"%ldh %@",hours,timetext];
    
    
    self.voiceLengthLabel.text = timetext;
    if(msgentity.state == DDmessageSendSuccess){
        self.voiceLengthLabel.hidden = NO;
        
    }
    else{
        self.voiceLengthLabel.hidden = YES;
    }
    return self;
}

@end

@implementation ChatVoiceRightCell

-(void)awakeFromNib{
    [super awakeFromNib];
    [self hideNick:YES];
    _cf = CHAT_RIGHT;
}
-(BOOL)setMessageEntity:(DDMessageEntity *)msgentity{
    if(msgentity.msgID == VOICE_PLACEHODER){
        [self.avatarImageView setUid:msgentity.senderId];
        self.anchorWidthCS.constant = 80;
        [self.anchorView setAudioAndLength:nil IsHttp:NO];
        [self hideMark];
        [self.anchorView startBlink];
        self.voiceLengthLabel.hidden = YES;
    }
    else{
        [self.anchorView stopBlink];
        [super setMessageEntity:msgentity];
    }
    return YES;
}

@end

@implementation ChatUnknowLeftCell

-(BOOL)setMessageEntity:(DDMessageEntity *)msgentity{
    BOOL ret = [super setMessageEntity:msgentity];
    if(ret){
        
        [self.anchorView setText:IMLocalizedString(@"未知消息类型", nil)];
    }
    return ret;
}

@end

@implementation ChatUnknowRightCell

-(void)awakeFromNib{
    [super awakeFromNib];
    [self hideNick:YES];
    _cf = CHAT_RIGHT;
    
}

@end
