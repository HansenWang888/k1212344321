//
//  ChatVideoCell.m
//  wdk12pad
//
//  Created by macapp on 16/2/25.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "ChatOtherCell.h"
#import "nameLabel.h"
#import "avatarImageView.h"
#import "SessionEntity.h"
#import "DDMessageEntity.h"
#import "MediaPlayer/MPMoviePlayerController.h"
#import "WDHTTPManager.h"
#import "WDMB.h"
#import "ChatCell.h"
@interface ChatOtherCell()

@property (weak, nonatomic) IBOutlet NameLabel *nameLabel;
@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@end

@implementation ChatOtherCell
- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer* avagesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onAvatarTap:)];
    [_avatarImageView addGestureRecognizer:avagesture];
    _avatarImageView.userInteractionEnabled = YES;

}
-(void)onAvatarTap:(id)sender{
    
    if(_avatarImageView.Uid&& ![_avatarImageView.Uid isEqualToString:TheRuntime.user.objID]){
        [[NSNotificationCenter defaultCenter]postNotificationName:SubNotify_AvatarTap object:_avatarImageView.Uid];
    }
}
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{
    if (msgentity.state == SessionTypeSessionTypeSubscription) {
        [_avatarImageView setSBID:msgentity.senderId];
        
        [_nameLabel setSBID:msgentity.senderId];
    } else {
        [_avatarImageView setUid:msgentity.senderId];
        
        [_nameLabel setUid:msgentity.senderId];
    }
    return true;
}

@end
@implementation ChatOtherVideoCell{
    SessionEntity* _sentity;
    DDMessageEntity* _msgentity;
    MPMoviePlayerController* _mpctrl;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    _mpctrl = [[MPMoviePlayerController alloc]init];
    
    
    _mpctrl.controlStyle=MPMovieControlStyleNone;
   
    _mpctrl.view.frame = CGRectMake(80, 30, 200, 140);
     // player的尺寸
    [self addSubview:_mpctrl.view];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onFullScreen) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEndFullScreen) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    
}

-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{

    [super setMessageEntity:msgentity];
        
    NSString* url_str = [msgentity.info objectForKey:@"httpurl"];
    url_str =  ImageFullUrl(url_str);
 //   NSLog(@"-------------%@",url_str);
    [_mpctrl setContentURL:[NSURL URLWithString:url_str]];
    UITapGestureRecognizer* ontap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ontap)];
    [_mpctrl.view addGestureRecognizer:ontap];
    return true;
}
-(void)ontap{
    
    [_mpctrl setFullscreen:YES animated:YES];
    
}
-(void)onFullScreen{
    [_mpctrl prepareToPlay];
    _mpctrl.controlStyle = MPMovieControlStyleFullscreen;
    //[_mpctrl play];
}
-(void)onEndFullScreen{
    _mpctrl.controlStyle = MPMovieControlStyleNone;
    [_mpctrl stop];
}
-(void)setSessionEntity:(SessionEntity*)sentity{
    _sentity = sentity;
}
@end
@interface ChatOtherFileCell()

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIView *borderView;

@end
@implementation ChatOtherFileCell{
    NSString* _fileUrl;
    NSString* _filetransUrl;
    NSString* _fileName;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap)];
    [self.borderView addGestureRecognizer:gesture];
    self.borderView.userInteractionEnabled = YES;
}
-(BOOL)setMessageEntity:(DDMessageEntity*)msgentity{
    
    [super setMessageEntity:msgentity];

    NSString* fileName = [msgentity.info objectForKey:FILE_NAME_KEY];
    _fileNameLabel.text = fileName;
    _fileUrl = [msgentity.info objectForKey:FILE_ORIGIN_KEY];
    _filetransUrl = [msgentity.info objectForKey:FILE_TRANS_KEY];
    _fileName = fileName;
    float fileSize = [[msgentity.info objectForKey:@"filesize"] integerValue] / 1024.0;
    NSString *suffix = _fileUrl.pathExtension;
    suffix = [suffix uppercaseString];
    UIImage *img = [UIImage imageNamed:[WDMB MBToAdjunctImage][suffix]];
    if (img == nil) {
        img = [UIImage imageNamed:@"file_document"];
    }
    self.fileImageView.image = img;
    self.fileSizeLabel.text = [NSString stringWithFormat:@"%.2f KB ",fileSize];

    return true;
}
-(void)onTap{
    
    if(_fileName==nil || [_fileName isEqualToString:@""]) {
        return;
    }
    
    if(_fileUrl==nil || [_fileUrl isEqualToString:@""]) {
        return;
    }
    
    NSString* extestion = [_fileUrl pathExtension];
    if(extestion==nil || [extestion isEqualToString:@""]) {
        return;
    }
    
    extestion = [extestion uppercaseString];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationRequestOpenFile object:@[_fileName,_fileUrl,_filetransUrl,extestion]];
    
}
@end
