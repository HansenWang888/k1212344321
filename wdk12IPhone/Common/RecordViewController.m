//
//  ViewController.m
//  录音和播放
//
//  Created by 老船长 on 15/12/28.
//  Copyright © 2015年 伟东. All rights reserved.
//

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WDHTTPManager.h"
@interface RecordViewController ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startRecord;

@property (weak, nonatomic) IBOutlet UIButton *playRecord;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
@property (weak, nonatomic) IBOutlet UIButton *endRecord;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@property (nonatomic,strong) NSTimer *playTimer;//play record timer
@property (nonatomic, strong) NSData *recordData;
@property (nonatomic, strong) NSURL *recordUrl;

@end
#define kRecordAudioFile @"myRecord.caf"

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAudioSessionWithCategory:AVAudioSessionCategoryPlayAndRecord];
    
//    [self setButtonTitleInNormal:@"\U0000e65c" highlight:@"\U0000e699" button:self.playRecord fontSize:45];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(kUSUALY_MARGIN_VALUE, 20, 35, 35);
    [self setButtonTitleInNormal:@"\U0000e64d" highlight:nil button:closeBtn fontSize:30];
    [closeBtn addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:closeBtn];
}
- (void)closeButtonClick {
//    [_audioRecorder deleteRecording];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setButtonTitleInNormal:(NSString *)normal highlight:(NSString *)highlight button:(UIButton *)btn fontSize:(CGFloat)size {

    btn.titleLabel.font = [UIFont fontWithName:@"iconfont" size:size];
    [btn setTitle:normal forState:UIControlStateNormal];
    [btn setTitle:highlight forState:UIControlStateSelected];
}
-(void)setAudioSessionWithCategory:(NSString *)category{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:category error:nil];
    [audioSession setActive:YES error:nil];
}

- (IBAction)recordButtonClick:(UIButton *)sender {
    if (self.audioRecorder.isRecording) {
        [self.audioRecorder pause];
        self.timer.fireDate=[NSDate distantFuture];//pause timer
        self.audioPlayer = nil;
        self.endRecord.enabled = YES;
        self.playRecord.enabled = YES;
        self.startRecord.selected = NO;
        return;
    }
    if (self.startRecord == sender && self.startRecord.selected != YES) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.endRecord.enabled = NO;
        self.playRecord.enabled = NO;
        self.startRecord.selected = YES;
        self.timer.fireDate = [NSDate distantPast];//开启定时器
        NSLog(@"%@",self.audioRecorder.url);
    }  else if(sender == self.endRecord){
        [self.audioRecorder stop];
        self.timer.fireDate=[NSDate distantFuture];
        self.progressV.progress = 0.0;
        self.timeLabel.text = @"00:00:00";
        timeInt = 0;
    } else {
        if (self.audioPlayer.isPlaying) {
            self.playTimer.fireDate=[NSDate distantFuture];
            [self.audioPlayer pause];
            self.startRecord.enabled = YES;
            self.playRecord.selected = NO;
        } else {
            [self.audioPlayer prepareToPlay];
            self.playTimer.fireDate = [NSDate distantPast];//开启定时器
            self.playRecord.selected = YES;
            self.startRecord.enabled = NO;
            [self.audioPlayer play];
        }
    }
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    self.recordData = [NSData dataWithContentsOfURL:recorder.url];
    self.recordUrl = recorder.url;
    if ([self.recordDelegate respondsToSelector:@selector(recordCompeletedWithRecordURL:recordData:)]) {
        [self.recordDelegate recordCompeletedWithRecordURL:[NSString stringWithFormat:@"%@",self.recordUrl] recordData:self.recordData];
    }
    self.endRecord.enabled = NO;
    self.playRecord.enabled = NO;
    //等数据过去了再关闭
    [self closeButtonClick];

}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.startRecord.enabled = YES;
    self.playRecord.selected = NO;
    
}
/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了ccc
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    return dicM;
}
long int timeInt = 0;
- (void)audioPowerChange {
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    timeInt += 6;
    CGFloat progress=(1.0/160.0)*(power+160.0);
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",timeInt / (3600 * 6),(timeInt / 3600) % 60,(timeInt / 60) % 60];
    [self.progressV setProgress:progress];
}
int playInt = 0;
- (void)playRecordChange {
    NSTimeInterval playTime = self.audioPlayer.duration;
    int a = round(playTime);
    playInt++;
    if (playInt > a) {
        self.playTimer.fireDate=[NSDate distantFuture];
        playInt = 0;
        return;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",playInt / 3600,(playInt / 60) % 60,playInt % 60];
}
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            WDULog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        _audioPlayer.delegate = self;
        if (error) {
            WDULog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}
-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}
-(NSTimer *)playTimer{
    if (!_playTimer) {
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(playRecordChange) userInfo:nil repeats:YES];
    }
    return _playTimer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [self.timer invalidate];
}

@end
