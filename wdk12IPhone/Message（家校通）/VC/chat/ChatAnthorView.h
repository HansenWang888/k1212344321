//
//  ChatAnthorView.h
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "FileModule.h"
#import "PlayerManager.h"
#import "AnthorTool.h"
@interface ChatAnthorView :UIView<DownLoadDelegate>
-(void)setText:(NSString*)text;
-(BOOL)setImageUrl:(NSString*)url;

-(void)setAudioAndLength:(NSString*)filepath IsHttp:(BOOL)ishttp;

-(void)startBlink;
-(void)stopBlink;

-(void)onDisappera;
@end


@interface ChatAnthorViewLeft : ChatAnthorView

@end

@interface ChatAnthorViewRight : ChatAnthorView

@end

@interface chatAnthorImageViewLeft : ChatAnthorViewLeft

@end


@interface chatAnthorVoiceViewLeft : ChatAnthorViewLeft

@end

@interface chatAnthorVoiceViewRight : ChatAnthorViewRight

@end

