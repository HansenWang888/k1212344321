#ifndef _file_module_h
#define _file_module_h

#import <Foundation/Foundation.h>

@class DDMessageEntity;

typedef void(^UploadBlock)(id respone,NSError* error);
typedef void(^DownloadBlock)(id respone,NSError* error);
@interface FileLoadModule : NSObject

@property (nonatomic,readonly)dispatch_queue_t downloadQueue;
+ (instancetype)shareInstance;
//-(BOOL)moveAudioFileToCache:(NSString*) before;

-(NSString*)copyImageCompress:(NSString*)oldfullpath;
-(BOOL)copyImage:(NSString*)oldfullpath;
-(BOOL)copyVoice:(NSString*)oldfullpath;
-(BOOL)imageExist:(NSString*)localpath;
-(BOOL)voiceExist:(NSString*)localpath;
-(BOOL)isInUploadQueue:(DDMessageEntity *)message;
-(id)init;
-(BOOL)fileExist:(NSString*)filePath;
-(BOOL)deleteFile:(NSString*)filePath;

-(void)UploadFile:(NSString*) filePath Block:(UploadBlock)block;
-(void)UpLoadImage:(NSString*) filename Block:(UploadBlock)block;
-(void)UpLoadAudio:(NSString*) filename Block:(UploadBlock)block;

-(NSString*)LocalAudioPath:(NSString*) localpath;
-(NSString*)LocalImagePath:(NSString*) localpath;
-(NSString*)LocalCacheFile:(NSString*) kttpkey;


-(void)DownLoadFile:(NSString*)url CachePath:(NSString*)path Block:(DownloadBlock)block;

-(void)DownLoadAudioFile:(NSString*) url   Block:(DownloadBlock)block;
-(void)DownLoadImageFile:(NSString*) url   Block:(DownloadBlock)block;

-(void)clear;

@end

NSString* GetMessageResourceUpdateKey();
#endif