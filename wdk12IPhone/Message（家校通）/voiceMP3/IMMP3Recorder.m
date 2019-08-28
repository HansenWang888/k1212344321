//
//  MP3Recorder.m
//  recorderMP3
//
//  Created by macapp on 2017/9/11.
//  Copyright © 2017年 macapp. All rights reserved.
//

#import "IMMP3Recorder.h"
#import "uikit/uikit.h"
#import <avfoundation/avfoundation.h>
#import "lame.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)



#pragma mark interrupt
@interface InterruptionHandler : NSObject
{
@public
    IMMP3Recorder* _source;
    
}
- (void) handleInterruption: (NSNotification*) notification;
@end
@implementation InterruptionHandler

- (void) handleInterruption:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    if([userInfo[AVAudioSessionInterruptionTypeKey] intValue] == AVAudioSessionInterruptionTypeBegan) {
       // _source->interruptionBegan();
    } else {
       // _source->interruptionEnded();
    }
}

@end
#define MP3_FRAME_MAX_BYTES 10240
#pragma mark mp3recorder
@implementation IMMP3Recorder{
    AudioComponentInstance _audioUnit;
    AudioComponent         _component;
    lame_t                 _lame;
    FILE*                  _mp3File;
    NSString*              _filePath;
    CGFloat                _interval;
    CGFloat                _sampleRate;
    int                    _channelPerFrame;
    uint8_t                _mp3buffer[MP3_FRAME_MAX_BYTES];
}
-(int)channelPerFrame{
    return _channelPerFrame;
}
+(instancetype)shareInstance{
    static IMMP3Recorder *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [IMMP3Recorder new];
        }
    });
    return _instance;
}
+(NSString*)recorderPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString* mp3Path = [docDir stringByAppendingPathComponent:@"voice"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:mp3Path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:mp3Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return mp3Path;

}
+(NSString*)timeMP3FilePath{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-S"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    //输出格式为：2010-10-27 10:22:13
    
    NSString* timeStr = [NSString stringWithFormat:@"%@.mp3",currentDateStr];
    timeStr = [NSString stringWithFormat:@"%f.mp3",[NSDate date].timeIntervalSince1970];
    NSString* filepath = [[IMMP3Recorder recorderPath]stringByAppendingPathComponent:timeStr];
    return filepath;
}

#pragma mark audiounit
-(AudioComponentInstance)audio_unit{
    return _audioUnit;
}
static OSStatus handleInputBuffer(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData)
{
    IMMP3Recorder* mc = (__bridge IMMP3Recorder*)inRefCon;
    
    AudioBuffer buffer;
    buffer.mData = NULL;
    buffer.mDataByteSize = 0;
    buffer.mNumberChannels = [mc channelPerFrame];
    
    AudioBufferList buffers;
    buffers.mNumberBuffers = 1;
    buffers.mBuffers[0] = buffer;
    
    OSStatus status = AudioUnitRender([mc audio_unit],
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      &buffers);
    if(!status) {
        [mc inputCallback:(uint8_t*)buffers.mBuffers[0].mData Size:buffers.mBuffers[0].mDataByteSize NumberFrames:inNumberFrames];

    }
    return status;
}
-(void)inputCallback:(uint8_t*)data Size:(size_t) data_size NumberFrames:(int) inNumberFrames{
    NSLog(@"%d,%d",data_size,inNumberFrames);
    
    int numout = lame_encode_buffer_interleaved(_lame, data, inNumberFrames,_mp3buffer, MP3_FRAME_MAX_BYTES);
    fwrite(_mp3buffer, numout, 1, _mp3File);
    
    
    _interval += inNumberFrames/_sampleRate;
    
    NSLog(@"%f",_interval);
}
#pragma mark recorde

-(BOOL)start{
    if(_audioUnit != nil){
        return NO;
    }
    [self startRecordeWithSampleRate:44100.f ChannelPerFrame:2];
    return YES;
}

-(void)forceStop{
    if(_audioUnit) {
        
        AudioOutputUnitStop(_audioUnit);
        AudioComponentInstanceDispose(_audioUnit);
        _audioUnit = NULL;
    }
    if(_lame){
        lame_close(_lame);
        _lame = NULL;
    }
    if(_mp3File){
        fclose(_mp3File);
        _mp3File = NULL;
        [[NSFileManager defaultManager]removeItemAtPath:_filePath error:nil];
    }
    //delete file
    
}
-(void)stop{
    if(_audioUnit) {
        AudioOutputUnitStop(_audioUnit);
        AudioComponentInstanceDispose(_audioUnit);
        _audioUnit = NULL;
    }
    if(_lame){
        lame_close(_lame);
        _lame = NULL;
    }
    if(_mp3File){
        fclose(_mp3File);
        _mp3File = NULL;
    }
    if(_delegate){
        [_delegate didFinished:_filePath Interval:_interval];
    }
}
#define RECORDE_INTERRUPT(quote) if(!(quote)) {\
[self forceStop];\
if(_delegate){\
[_delegate interrupted:nil];\
}\
}
-(void)startRecordeWithSampleRate:(CGFloat)sampleRate ChannelPerFrame:(int)channelPerFrame{
    _lame = lame_init();
    RECORDE_INTERRUPT(_lame);
    lame_set_in_samplerate(_lame, sampleRate);
    lame_set_num_channels(_lame, channelPerFrame);
    lame_set_VBR(_lame, vbr_default);
    lame_init_params(_lame);
    
    _filePath = [IMMP3Recorder timeMP3FilePath] ;
    _mp3File = fopen([_filePath UTF8String], "wb");
    RECORDE_INTERRUPT(_mp3File);
    NSLog(@"%@",_filePath);
    
    _interval = 0.f;
    _sampleRate = sampleRate;
    _channelPerFrame = channelPerFrame;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    

    PermissionBlock permission = ^(BOOL granted) {
        if(granted) {
            OSStatus stat;
            [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers error:nil];
            //[session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:0 error:nil];
            [session setMode:AVAudioSessionModeVideoChat error:nil];
            [session setActive:YES error:nil];
            
            AudioComponentDescription acd;
            acd.componentType = kAudioUnitType_Output;
            acd.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
            acd.componentManufacturer = kAudioUnitManufacturer_Apple;
            acd.componentFlags = 0;
            acd.componentFlagsMask = 0;
            
            _component = AudioComponentFindNext(NULL, &acd);
            
            AudioComponentInstanceNew(_component, &_audioUnit);
            RECORDE_INTERRUPT(_component);
//            if(excludeAudioUnit) {
//                excludeAudioUnit(bThis->m_audioUnit);
//            }
            UInt32 flagOne = 1;
            
            stat = AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flagOne, sizeof(flagOne));
            RECORDE_INTERRUPT(stat==noErr);
            AudioStreamBasicDescription desc = {0};
            desc.mSampleRate = sampleRate;
            desc.mFormatID = kAudioFormatLinearPCM;
            desc.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked);
            desc.mChannelsPerFrame = channelPerFrame;
            desc.mFramesPerPacket = 1;
            desc.mBitsPerChannel = 16;
            desc.mBytesPerFrame = desc.mBitsPerChannel / 8 * desc.mChannelsPerFrame;
            desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
            
            AURenderCallbackStruct cb;
            cb.inputProcRefCon = (__bridge void*)self;
            cb.inputProc = handleInputBuffer;
            AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &desc, sizeof(desc));
            AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &cb, sizeof(cb));
            UInt32 echoCancellation;
            UInt32 size = sizeof(echoCancellation);
            AudioUnitGetProperty(_audioUnit,
                                 kAUVoiceIOProperty_BypassVoiceProcessing,
                                 kAudioUnitScope_Global,
                                 0,
                                 &echoCancellation,
                                 &size);
            uint32_t agc;
            AudioUnitGetProperty(_audioUnit,
                                 kAUVoiceIOProperty_VoiceProcessingEnableAGC,
                                 kAudioUnitScope_Global,
                                 0,
                                 &agc,
                                 &size);
            uint32_t mutes;
            AudioUnitGetProperty(_audioUnit,
                                 kAUVoiceIOProperty_MuteOutput,
                                 kAudioUnitScope_Global,
                                 0,
                                 &mutes,
                                 &size);
//            m_interruptionHandler = [[InterruptionHandler alloc] init];
//            m_interruptionHandler->_source = this;
//            
//            [[NSNotificationCenter defaultCenter] addObserver:m_interruptionHandler selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
            
            AudioUnitInitialize(_audioUnit);
            stat = AudioOutputUnitStart(_audioUnit);
            RECORDE_INTERRUPT(stat==noErr);
            if(stat != noErr) {
                NSLog(@"Failed to start microphone!");
            }
        }
    };
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [session requestRecordPermission:permission];
    } else {
        permission(true);
    }
    
    

}

@end
