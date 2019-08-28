//
//  MoviePlayerControllerViewController.m
//  WdEduApp-i
//
//  Created by 布依男孩 on 15/9/9.
//  Copyright (c) 2015年 macapp. All rights reserved.
//

#import "MoviePlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface MoviePlayerController()
@property (nonatomic, strong) UIView *containView;//视频显示容器
@property (nonatomic, strong) AVPlayer *moviePlayer;//播放器对象
@property (nonatomic, strong) UIButton *playBtn;//播放按钮
@property (nonatomic, strong) UIView *playContain;//播放显示栏
@property (nonatomic, strong) UIProgressView *progressV;//进度条
@property (nonatomic, assign) int totalTime;//视频总时间
@property (nonatomic, strong) UILabel *timeLabel;//显示时间
@property (nonatomic, strong) UIButton *closeBtn;//关闭按钮
@property (nonatomic, strong) NSURL *playerURL;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *topView;
@property (assign, nonatomic) BOOL isLoading;//是否正在加载


@end
@implementation MoviePlayerController

- (void)viewDidLoad{
    [self.view addSubview:self.containView];
    [self.view addSubview:self.playContain];
    [self.view addSubview:self.topView];
    self.titleLabel.text = self.titleAsset;
    [self addNotification];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)stepUIAndURL:(NSURL *)url{
    [SVProgressHUD showWithStatus:nil];
    self.isLoading = YES;
    CGRect screenSize = [UIScreen mainScreen].bounds;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.moviePlayer = [AVPlayer playerWithPlayerItem:item];
    //添加更新
    [self addPlayerProgress];
    //添加监听
    [self addObserverPlayerItem:item];
    self.playerURL = url;
    //创建播放层
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
    layer.bounds = CGRectMake(0, 0, screenSize.size.height, screenSize.size.width);
    layer.position = CGPointMake(screenSize.size.width, 0);
    layer.videoGravity = AVLayerVideoGravityResize;
    CATransform3D landscapeTransform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
    layer.transform = landscapeTransform;
    //以左上角为原点旋转
    layer.anchorPoint = CGPointMake(0, 0);
    
    self.containView = [[UIView alloc] initWithFrame:screenSize];
    self.containView.backgroundColor = [UIColor whiteColor];
    [self.containView.layer addSublayer:layer];
}
- (void)closeMoviePlay{
    //弹出控制器
    [self dismissViewControllerAnimated:YES completion:nil];
}
//为播放器添加进度更新
- (void)addPlayerProgress{
    
    AVPlayerItem *item = self.moviePlayer.currentItem;
    //设置进度更新没一秒钟更新一次,主线程更新
    __weak typeof(self) weakSelf = self;
    //添加时间间隔
    [self.moviePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float currentTime = CMTimeGetSeconds(time);
        float totalTime = CMTimeGetSeconds(item.duration);
        weakSelf.totalTime = (int)totalTime;
        //设置进度条显示
        if (currentTime) {
            [weakSelf.progressV setProgress:currentTime / totalTime animated:YES];
           // NSLog(@"%f",currentTime / totalTime);
        }
        //使显示时间不断减少
        totalTime = totalTime - currentTime;
        NSString *str = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)totalTime / 3600,(int)totalTime / 60,(int)totalTime % 60];
        weakSelf.timeLabel.text = str;
    }];
}
//为item添加监听
- (void)addObserverPlayerItem:(AVPlayerItem *)item{
    //监听状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听网络加载情况
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
//监听响应方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    //获取监控的对象
    AVPlayerItem *playerItem = object;
    //如果是状态属性
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            int total = (int)CMTimeGetSeconds(playerItem.duration);
            //设置总显示时间
            NSString *str = [NSString stringWithFormat:@"%02d:%02d:%02d",total/3600,total / 60,total % 60];
            self.timeLabel.text = str;
        }
        //如果网络加载属性
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        NSLog(@"---%@-",array);
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        //本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.duration);
        float durationSeconds = CMTimeGetSeconds(playerItem.duration);
        float totalBuffer = startSeconds / durationSeconds;
        if (totalBuffer * 100 > 2 && self.isLoading) {
            self.isLoading = NO;
            [SVProgressHUD dismiss];
            [self playMovie:self.playBtn];
        }
        //缓冲总长度
        NSLog(@"共缓冲：\%f",totalBuffer * 100);
    }
}
//删除监听
- (void)removeObserverForPlayerItem:(AVPlayerItem *)item{
    
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

//MARK:去除通知
- (void)removeNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
}
//添加通知,监听视频播放完成
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerCompleted) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBackStall) name:AVPlayerItemPlaybackStalledNotification object:nil];

}
- (void)playerBackStall {
    self.isLoading = YES;
    [SVProgressHUD showWithStatus:nil];
    _playBtn.selected = NO;
}
//视频播放完成
- (void)playerCompleted{
    _playBtn.selected = NO;
    self.playContain.alpha = 1.0;
    self.topView.alpha = 1.0;
    CMTime time = CMTimeMakeWithSeconds(0.5, 1);
    [self.moviePlayer seekToTime:time completionHandler:^(BOOL finished) {
        
    }];
//    [self.moviePlayer seekToTime:time toleranceBefore:nil toleranceAfter:nil completionHandler:nil];
}
- (void)dealloc{
    
    [self removeObserverForPlayerItem:self.moviePlayer.currentItem];
    [self removeNotification];
}
//播放视频
- (void)playMovie:(UIButton *)sender {
    
    //如果是暂停
    if (self.moviePlayer.rate == 0) {
        sender.selected = YES;
        [self.moviePlayer play];
        //设置5倍的播放速度
//        self.moviePlayer.rate = 20;
    }else if (self.moviePlayer.rate > 0){
        //如果是播放就选择暂停
        [self.moviePlayer pause];
        sender.selected = NO;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.playContain.alpha = 0.0;
            self.topView.alpha = 0.0;
        }];
    });
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //显示播放控制View
    if (self.playContain.alpha == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.playContain.alpha = 1.0;
            self.topView.alpha = 1.0;
        }];
    } else {
        //再次点击隐藏
        [UIView animateWithDuration:0.5 animations:^{
            self.playContain.alpha = 0.0;
            self.topView.alpha = 0.0;
        }];
    }
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
//懒加载
- (UIButton *)closeBtn{
    
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        _closeBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 10, 50, 50);
        [_closeBtn setTitle:NSLocalizedString(@"关闭", nil) forState:UIControlStateNormal];
        _closeBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
        [_closeBtn addTarget:self action:@selector(closeMoviePlay) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn sizeToFit];
        
    }
    return _closeBtn;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        
        float mix = CGRectGetMaxX(self.progressV.frame);
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(mix + 10, 20, 50, 30)];
        self.timeLabel.text = @"88:88:88";
        [_timeLabel sizeToFit];
    }
    return  _timeLabel;
}
- (UIProgressView *)progressV{
    
    if (!_progressV) {
        _progressV = [[UIProgressView alloc] initWithFrame:CGRectMake(55,30,self.view.frame.size.height / 2 - 120,30)];
        _progressV.trackTintColor = [UIColor whiteColor];
    }
    return _progressV;
}
- (UIView *)playContain{
    
    if (!_playContain) {
        _playContain = [[UIView alloc] init];
        _playContain.frame = CGRectMake(-100, self.view.center.y - 32, self.view.frame.size.height / 2 + 20, 60);
        
        _playContain.transform = CGAffineTransformMakeRotation(M_PI_2);
        UIVisualEffectView *visual = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        visual.frame = _playContain.bounds;
        visual.alpha = 0.5;
        _playContain.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [_playContain addSubview:visual];
        [_playContain addSubview:self.playBtn];
        [_playContain addSubview:self.progressV];
        [_playContain addSubview:self.timeLabel];
    }
    return _playContain;
}
//懒加载播放按钮
- (UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"download_begain"] forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"download_pause"] forState:UIControlStateSelected];
        _playBtn.frame = CGRectMake(10, 13, 35, 35);
        [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _playBtn.alpha = 1.0;
        [_playBtn addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}
- (UIView *)topView {
    if (!_topView) {
        CGFloat H = CURRENT_DEVICE_SIZE.height;
        CGFloat W = 44;
        CGFloat Y = 0;
        CGFloat X = CURRENT_DEVICE_SIZE.width - W;
        _topView.transform = CGAffineTransformMakeRotation(M_PI_2);
        _topView = [[UIView alloc] initWithFrame:CGRectMake(X, Y, W, H)];
        _topView.backgroundColor = [UIColor grayColor];
        UIVisualEffectView *visual = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        visual.frame = _topView.bounds;
        visual.alpha = 0.5;
        _topView.alpha = 0.8;
        [_topView addSubview:visual];
        self.closeBtn.frame = CGRectMake((_topView.bounds.size.width - 35) * 0.5, 8, 35, 35);
        [_topView addSubview:self.closeBtn];
        self.titleLabel.frame = _topView.bounds;
        [_topView addSubview:self.titleLabel];
    }
    return _topView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
//        CGFloat H = CURRENT_DEVICE_SIZE.height - 100;
//        CGFloat W = 50;
//        CGFloat Y = (CURRENT_DEVICE_SIZE.height - H) * 0.5;
//        CGFloat X = CURRENT_DEVICE_SIZE.width - W - 20;
        _titleLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
//        _titleLabel.frame = CGRectMake(X , Y, W, H);
        _titleLabel.font = [UIFont systemFontOfSize:18];
//        _titleLabel.backgroundColor = [UIColor orangeColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}
@end
