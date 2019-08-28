#import "filemodule.h"
#import "SDWebImageManager.h"
#import "AFNetworking.h"
#import "NSDictionary+R.h"
#import "UIImage+FullScreen.h"
typedef enum{
    Voice,
    Image
}TaskScheme;

@interface DataTaskDescriptor : NSObject



@property NSURLSessionDataTask* task;
@property NSString*             originUrl;
@property NSMutableData*        data;


-(long long)recivedData;
-(void)setRecivedData:(long long)v;

-(long long)expectedData;
-(void)setExpectedData:(long long)v;

-(void)setCompletion:(BOOL)finished;

@property(nonatomic) TaskScheme scheme;


-(void)insertDelegate:(id<DownLoadDelegate>)delegate;
-(void)removeDelegate:(id<DownLoadDelegate>)delegate;
@end
@implementation DataTaskDescriptor
{
    NSMutableArray< id<DownLoadDelegate>>* _delegates;
    long long _recivedData;
    long long _expectedData;
}
-(id)init{
    self = [super init];
    _data = [NSMutableData new];
    _recivedData = 0;
    _expectedData = 1;
    
    _delegates = [NSMutableArray new];
    return self;
}
-(void)dealloc{
    
}
-(long long)recivedData{
    return _recivedData;
}
-(void)setRecivedData:(long long)v{
    
    _recivedData = v;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegates enumerateObjectsUsingBlock:^( id<DownLoadDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [obj onReciveData:_recivedData Expect:_expectedData];
        }];
    });
    
}
-(long long)expectedData{
    return _expectedData;
}
-(void)setExpectedData:(long long)v{
    _expectedData = v;
}
-(void)setCompletion:(BOOL)finished{
    
    if(_scheme == Image){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            BOOL rellayFinished = NO;
            do{
                if(!finished) break;
                UIImage* image = [UIImage imageWithData:_data];
                if(!image) break;
                UIImage* smallimage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(110, 140) ];
                if(!smallimage) break;
                
                SDWebImageManager* manager = [SDWebImageManager sharedManager];
                [manager saveImageToCache:image forURL:[NSURL URLWithString:_originUrl]];
                [manager saveImageToCache:smallimage forURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_abs",_originUrl]]];
                rellayFinished = YES;
            }while (0);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegates enumerateObjectsUsingBlock:^( id<DownLoadDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    [obj Compeletion:rellayFinished];
                }];
            });
            
        });
    }
    else if(_scheme == Voice){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL reallyFinished = NO;
            do{
                if(!finished) break;
                
                NSString* filename = [_originUrl lastPathComponent];
                NSString* localPath = [[FileModule shareInstance]getLocalVoiceFilePath:filename];
                reallyFinished =   [_data writeToFile:localPath atomically:YES];
                
                
            }while(0);

            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegates enumerateObjectsUsingBlock:^( id<DownLoadDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    [obj Compeletion:reallyFinished];
                }];
            });
            
        });
        

    }
    
}
-(void)insertDelegate:(id<DownLoadDelegate>)delegate{
    [_delegates addObject:delegate];
}
-(void)removeDelegate:(id<DownLoadDelegate>)delegate{
    [_delegates removeObject:delegate];
}
@end

@implementation FileModule
{
    AFHTTPSessionManager* _manager;
    NSURLSession*         _downloadSession;
    
    NSMutableDictionary<NSString*,DataTaskDescriptor*>*  _tasks;
    
    NSMutableDictionary<NSURLSessionDataTask*,DataTaskDescriptor*>* _fastTaskMap;
    
    NSString* _voicePath;
}
+ (instancetype)shareInstance{
    
    static FileModule* g_FileModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_FileModule = [[FileModule alloc] init];
    });
    return g_FileModule;
    
}
+(NSString*) homeDirectory{
    
    
    static NSString* homedictory  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        
        homedictory = [paths objectAtIndex:0];
        
    });
    return homedictory;
}
-(BOOL)isLocalVoiceFileExist:(NSString*)fileName{
    NSString* localpath = [_voicePath stringByAppendingPathComponent:fileName];
    
    
   return  [[NSFileManager defaultManager]fileExistsAtPath:localpath];
}
-(NSString*)getLocalVoiceFilePath:(NSString*)fileName{
    return [_voicePath stringByAppendingPathComponent:fileName];
}
-(id)init{
    
    self = [super init];
    _manager = [AFHTTPSessionManager manager];
    _downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    _tasks = [NSMutableDictionary new];
    _fastTaskMap = [NSMutableDictionary new];
    [self createVoicePath];
    return self;
    
}
-(void)createVoicePath{
    _voicePath = [[FileModule homeDirectory]stringByAppendingPathComponent:@"voice"];
    
    BOOL _isdic;
    BOOL _isexist;
    _isexist =[[NSFileManager defaultManager]fileExistsAtPath:_voicePath isDirectory:&_isdic];

    if(!_isexist){
        [[NSFileManager defaultManager]createDirectoryAtPath:_voicePath withIntermediateDirectories:nil attributes:nil error:nil];
    }
}
-(void)uploadImage:(UIImage*)image Name:(NSString*)name  Block:(UploadCompletion)block{
    
    //
    NSData* imagedata =  UIImageJPEGRepresentation(image,1.0);
    [_manager POST:TheRuntime.fastdfsupload parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imagedata name:@"files" fileName:name mimeType:@"image/jpeg"];
        
    }progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSString* fileid = [NSDictionary recursiveObjectForKey:@"fileId" Dic:responseObject];
        
        if(fileid != nil){
            block(nil,fileid);
        }
        else{
            block([NSError errorWithDomain:@"fileid==nil" code:0 userInfo:nil],nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        block(error,nil);
    }];
    
    
}
-(void)uploadAudio:(NSData*)data Name:(NSString*)name Block:(UploadCompletion)block{
    
    NSString* v = TheRuntime.fastdfsupload;
    
    [_manager POST:TheRuntime.fastdfsupload parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data name:@"files" fileName:name mimeType:@"application/octet-stream"];
        
    }progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSString* fileid = [NSDictionary recursiveObjectForKey:@"fileId" Dic:responseObject];
        
        if(fileid != nil){
            block(nil,fileid);
        }
        else{
            block([NSError errorWithDomain:@"fileid==nil" code:0 userInfo:nil],nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        block(error,nil);
    }];
}


-(void)removeDelegate:(id<DownLoadDelegate>) delegate StringUrl:(NSString*) url_str{
    NSURL* url = [NSURL URLWithString:url_str];
    DataTaskDescriptor* des = [_tasks objectForKey:[url absoluteString]];
    if(des) {
        [des removeDelegate:delegate];
    }
}

-(void)downLoadVoice:(NSString*)url_str Delegate:(id<DownLoadDelegate>)delegate{
    DataTaskDescriptor* des = [_tasks objectForKey:url_str];
    
    if(des) {
        [des insertDelegate:delegate];
        [delegate onReciveData:des.recivedData Expect:des.expectedData];
        return;
    }
    
    
    
    
    NSURLSessionDataTask* task = [_downloadSession dataTaskWithURL:[NSURL URLWithString:url_str]];
    
    
    des = [[DataTaskDescriptor alloc]init];
    des.scheme = Voice;
    des.originUrl = url_str;
    [des insertDelegate:delegate];
    [delegate onReciveData:0 Expect:1];
    
    [_tasks setObject:des forKey:url_str];
    
    [task resume];
    
}

-(void)downLoadImage:(NSString*)url_str Delegate:(id<DownLoadDelegate>)delegate{
    
    DataTaskDescriptor* des = [_tasks objectForKey:url_str];
    
    if(des) {
        [des insertDelegate:delegate];
        [delegate onReciveData:des.recivedData Expect:des.expectedData];
        return;
    }
    
    
    
    
    NSURLSessionDataTask* task = [_downloadSession dataTaskWithURL:[NSURL URLWithString:url_str]];
    
    
    des = [[DataTaskDescriptor alloc]init];
    des.scheme = Image;
    des.originUrl = url_str;
    [des insertDelegate:delegate];
    [delegate onReciveData:0 Expect:1];
    
    [_tasks setObject:des forKey:url_str];
    
    [task resume];
    
    
    
}




/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    
    NSURL* url = dataTask.currentRequest.URL;
    
    NSString* url_str = [url absoluteString];
    
    DataTaskDescriptor* des =  [_tasks objectForKey:url_str];
    
    if(des){
        [des.data appendData:data];
        [des setRecivedData:des.data.length];
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    
    NSURL* url = task.currentRequest.URL;
    
    NSString* url_str = [url absoluteString];
    
    DataTaskDescriptor* des =  [_tasks objectForKey:url_str];
    
    if(des){
        if(error){
            [des setCompletion:NO];
        }
        else {
            [des setCompletion:YES];
        }
        
        
        [_tasks removeObjectForKey:url_str];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    
    
    BOOL enableDownload = NO;
    
    
    NSURL* url = dataTask.currentRequest.URL;
    
    NSString* url_str = [url absoluteString];
    
    DataTaskDescriptor* des =  [_tasks objectForKey:url_str];
    
    
    do{
        if(! [response isKindOfClass:[NSHTTPURLResponse class]]) break;
        
        
        
        NSHTTPURLResponse* respone = (NSHTTPURLResponse*)response;
        
        
        
        if(respone.statusCode != 200) break;
        NSLog(@"%@",response.MIMEType);
        
        if([response.MIMEType containsString:@"html"]||[response.MIMEType containsString:@"text"]) break;
//        if(![respone.MIMEType containsString:@"octet-stream"] &&
//           ![respone.MIMEType containsString:@"image"]) break;
        
        long long ex = respone.expectedContentLength;
        enableDownload = YES;
        if(des) des.expectedData = respone.expectedContentLength;
    }while (0);
    
    
    if(enableDownload){
        completionHandler(NSURLSessionResponseAllow);
    }
    else{
        completionHandler(NSURLSessionResponseCancel);
        
        
        if(des){
            [des setCompletion:NO];
        }
        [_tasks removeObjectForKey:url_str];
        
    }
    
}






@end