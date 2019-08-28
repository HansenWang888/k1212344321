//
//  InviteRightCell.m
//  wdk12pad-HD-T
//
//  Created by 老船长 on 16/4/7.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "InviteRightCell.h"
#import "avatarImageView.h"
#import "nameLabel.h"
#import "DDMessageEntity.h"
#import "SessionEntity.h"
#import "SubscribeInfoController.h"
#import "MessageDataModel.h"
#import "SubscribeModule.h"
#import "SubscribeEntity.h"
#import <UIImageView+WebCache.h>
@interface InviteRightCell ()

@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property ( weak, nonatomic) IBOutlet UIView *anchorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorWidthCS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorHeightCS;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UIImageView *faildMark;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorTopCS;
@property (weak, nonatomic) IBOutlet UILabel *voiceLengthLabel;

@property (weak, nonatomic) IBOutlet UIImageView *subscribeAvatarV;
@property (weak, nonatomic) IBOutlet UILabel *subscribeNameLabel;
@property (nonatomic, strong) DDMessageEntity *msgentity;
@property (nonatomic, strong) SessionEntity* sentity;
@property (nonatomic, strong) SubscribeEntity *subEntity;

@end
//NSString* const SubNotify_AvatarTap = @"SubNotify_AvatarTap";

@implementation InviteRightCell{
    NSString* _tid;
}
-(void)layoutSubviews{
    [super layoutSubviews];
//    self.anchorView.maskView.frame = self.anchorView.bounds;
}
- (void)awakeFromNib {
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SenderText_bj"]];
    imgV.frame = CGRectMake(0, 0, 200, 80);
//    self.anchorView.maskView = imgV;
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
    self.anchorView.userInteractionEnabled = YES;
    UITapGestureRecognizer* anchorTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(subscribeInfo)];
    [self.anchorView addGestureRecognizer:anchorTap];
}
-(void)subscribeUpdate:(NSNotification*)notify{
    NSString* sbid = notify.object[0];
    SubscribeUpdateType updtype = [notify.object[1] integerValue];
    if(updtype == SubscribeUpdateTypeInfo){
        [self subscribeUpdateImpl:sbid];
    }

}
-(void)subscribeUpdateImpl:(NSString*)sbid{
    if(![sbid isEqualToString:_tid]) return;
    _subEntity = [[SubscribeModule shareInstance]getSBInfoWithNotification:sbid ForUpdate:NO];
    if(_subEntity){
        [self.subscribeAvatarV sd_setImageWithURL:[NSURL URLWithString:ImageFullUrl(_subEntity.avatar)] placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
        self.subscribeNameLabel.text = _subEntity.name;
        self.descLabel.text = _subEntity.introduce;
    }
}
- (void)subscribeInfo {
    SubscribeInfoController *vc = [[SubscribeInfoController alloc] initWithSBID:_subEntity.objID];
//    [g_SplitVC.rightNav pushViewController:vc animated:YES];
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
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{
    //if(_msgentity == msgentity) return NO;
    _msgentity = msgentity;
    
    if(_sentity.sessionType == SessionTypeSessionTypeSubscription&&![msgentity.senderId isEqualToString:TheRuntime.user.objID]){
        [_avatarImageView setSBID:msgentity.senderId];
    }
    else{
        [_avatarImageView setUid:msgentity.senderId];
    }
    
    if(_sentity.sessionType == SessionTypeSessionTypeGroup){
    }
    else{
        if(_sentity.sessionType == SessionTypeSessionTypeSubscription&&![msgentity.senderId isEqualToString:TheRuntime.user.objID]){
        }
        else{
        }
    }
    
    [self hideMark];
    if(msgentity.state == DDMessageSending) {
        [_indicatorView startAnimating];
    }
    else if(msgentity.state == DDMessageSendFailure) {
        [_faildMark setHidden:NO];
    }
    
    uint64_t tid = [msgentity.info[@"target"] longLongValue];
    SessionType stype = [msgentity.info[@"targetType"] integerValue];
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if(stype == SessionTypeSessionTypeSubscription){
        NSString* sb_id = [TheRuntime changeOriginalToLocalID:tid SessionType:stype];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subscribeUpdate:) name:DDNotificationSubscribeInfoUpdate object:nil];
        _tid = sb_id;
        [self subscribeUpdateImpl:_tid];
        
    }
    
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
    }
    else {
        self.anchorTopCS.constant = 25;
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
