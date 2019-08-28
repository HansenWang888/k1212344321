//
//  MP3Recorder.h
//  recorderMP3
//
//  Created by macapp on 2017/9/11.
//  Copyright © 2017年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MP3RecorderDelegate <NSObject>
@required
-(void)interrupted:(NSError*)error;
-(void)didFinished:(NSString*)filePath Interval:(NSTimeInterval)interval;
@end

@interface IMMP3Recorder : NSObject
+(instancetype)shareInstance;
+(NSString*)timeMP3FilePath;
+(NSString*)recorderPath;
-(BOOL)start;
-(void)stop;
-(void)forceStop;
@property (nonatomic) id<MP3RecorderDelegate> delegate;
@end
