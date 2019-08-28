#import <foundation/foundation.h>
#import <UIKIT/UIKIT.H>


typedef void(^UploadCompletion)(NSError* ,NSString* );

typedef void(^DownLoadCompletion)(NSError*,NSData*);


typedef enum {
    SUCCESS,
    ERROR_MIMETYPE,
    OTHER
}DownLoadCompetionCode;

@protocol DownLoadDelegate <NSObject>

@required
-(void)onReciveData:(long long)recivedSize Expect:(long long)expectSize;
-(void)Compeletion:(BOOL )finished;
@end



@interface FileModule : NSObject<NSURLSessionDataDelegate>
+ (instancetype)shareInstance;
-(void)uploadImage:(UIImage*)image Name:(NSString*)name  Block:(UploadCompletion)block;

-(void)uploadAudio:(NSData*)data Name:(NSString*)name Block:(UploadCompletion)block;


-(void)removeDelegate:(id<DownLoadDelegate>) delegate StringUrl:(NSString*) url;

-(void)downLoadImage:(NSString*)url Delegate:(id<DownLoadDelegate>)delegate;
-(void)downLoadVoice:(NSString*)url Delegate:(id<DownLoadDelegate>)delegate;

-(BOOL)isLocalVoiceFileExist:(NSString*)fileName;
-(NSString*)getLocalVoiceFilePath:(NSString*)fileName;
@end