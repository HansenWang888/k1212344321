//
//  IMChatShareCell.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 2016/12/12.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "IMChatShareCell.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "DDMessageEntity.h"
#import "SessionEntity.h"
#import "SubscribeInfoController.h"
#import "MessageDataModel.h"
#import "SubscribeModule.h"
#import "SubscribeEntity.h"
#import <UIImageView+WebCache.h>
#import "HyperLinkVC.h"

@interface IMChatShareCell ()
@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property ( weak, nonatomic) IBOutlet UIView *anchorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorWidthCS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorHeightCS;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *faildMark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorTopCS;
@property (weak, nonatomic) IBOutlet NameLabel *namelabel;

@property (nonatomic, strong) DDMessageEntity *msgentity;
@property (nonatomic, strong) SessionEntity* sentity;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *infoLable;
@property (weak, nonatomic) IBOutlet UIImageView *shareImgV;

@end
@implementation IMChatShareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SenderText_bj"]];
    imgV.frame = CGRectMake(0, 0, 200, 80);
    UIImage* image =  [[UIImage imageNamed:@"gantanhao"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_faildMark setImage:image];
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onResend:)];
    [_faildMark addGestureRecognizer:gesture];
    _faildMark.tintColor = [UIColor redColor];
    [self hideMark];
    UITapGestureRecognizer* avagesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onAvatarTap:)];
    [_avatarImageView addGestureRecognizer:avagesture];
    _avatarImageView.userInteractionEnabled = YES;
    self.anchorView.userInteractionEnabled = YES;
    UITapGestureRecognizer* anchorTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareInfo)];
    [self.anchorView addGestureRecognizer:anchorTap];
    self.anchorView.layer.cornerRadius = 5;
    self.anchorView.layer.masksToBounds = YES;
    self.anchorView.layer.borderColor = COLOR_Creat(0.64, 0.78, 0.33, 0.8).CGColor;
    self.anchorView.layer.borderWidth = 0.5;
    [self hideNick:![self.reuseIdentifier isEqualToString:@"Share_left"]];
}

- (void)shareInfo {
    NSString *link = _msgentity.info[@"link"];
    NSString *type = _msgentity.info[@"type"];
    NSString *title = _msgentity.info[@"title"];
    if ([type isEqualToString:@"link"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReqeustHyperLink object:@[_sentity.sessionID,link,title]];
    }

}

- (void)onResend:(id)sender {
    
    if(_msgentity.state == DDMessageSendFailure){
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationResendMessage object:_msgentity];
    }
}
-(void)onAvatarTap:(id)sender{
    
    if(_avatarImageView.Uid&& ![_avatarImageView.Uid isEqualToString:TheRuntime.user.objID]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SubNotify_AvatarTap" object:_avatarImageView.Uid];
    }
}
-(void)setSessionEntity:(SessionEntity*)sentity{
    _sentity = sentity;
}
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{
   
    _msgentity = msgentity;
    
    if(_sentity.sessionType == SessionTypeSessionTypeSubscription&&![msgentity.senderId isEqualToString:TheRuntime.user.objID]){
        [_avatarImageView setSBID:msgentity.senderId];
    }
    else{
        [_avatarImageView setUid:msgentity.senderId];
    }
    
    if(_msgentity.sessionType == SessionTypeSessionTypeGroup){
        [_namelabel setUid:msgentity.senderId WithGID:_sentity.sessionID];
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
    
    NSString *title = msgentity.info[@"title"];
    NSString *desc = msgentity.info[@"desc"];
    NSString *imgUrl = msgentity.info[@"imageUrl"];
    self.titleLable.text = title;
    self.infoLable.text = desc;
    [self.shareImgV sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"holdHeadImage"]];
    
    
    
    return YES;
}
-(void)messageUpdate:(NSNotification*)notify{
    
    NSString* sessionid = [notify.object objectAtIndex:0];
    if(![sessionid isEqualToString:_sentity.sessionID]) return;
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
        }
    }
}

-(void)hideNick:(BOOL)hide{
    if(hide){
        self.anchorTopCS.constant = 8;
        self.namelabel.hidden = YES;
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
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
