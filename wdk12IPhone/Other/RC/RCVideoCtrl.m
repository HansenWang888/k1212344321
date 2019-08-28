//
//  RCVideoCtrl.m
//  wdk12pad
//
//  Created by macapp on 15/12/30.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import "RCVideoCtrl.h"
#import "MediaPlayer/MPMoviePlayerController.h"

@interface RCVideoCtrl()
@end

@implementation RCVideoCtrl
{
    MPMoviePlayerController* _mpctrl;
}

-(void)start{
    
    _mpctrl = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:self.path]];
    _mpctrl.controlStyle=MPMovieControlStyleDefault;
    if ([self.path hasPrefix:@"file"]) {
        _mpctrl.movieSourceType = MPMovieSourceTypeUnknown;
    }
       [_mpctrl prepareToPlay];
    [_mpctrl.view setFrame:self.vc.view.bounds];// player的尺寸
    [self.vc.view addSubview: _mpctrl.view];
    _mpctrl.shouldAutoplay=YES;
    if (_mpctrl.movieMediaTypes == MPMovieMediaTypeMaskAudio) {
        NSLog(@"%lu",(unsigned long)_mpctrl.movieMediaTypes);
    }
}
-(void)dealloc{
    if(_mpctrl){
        [_mpctrl setFullscreen:NO];
        [_mpctrl stop];
    }
    
}
@end
