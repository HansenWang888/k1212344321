#import "FileLoadModule.h"
#import "AFHTTPSessionManager.h"
#import "RuntimeStatus.h"
#import "AFNetworking.h"
#import "DDMessageEntity.h"
#import "FMDB.h"
#import "NSDictionary+Safe.h"
#import "DDDatabaseUtil.h"

//#define UPLOADURL @"wdcloud-wjfw/rest/fileWS/upload"

#define UPLOADURL  TheRuntime.fastdfsupload
#define FASTDFS TheRuntime.fastdfsdownload

#define IMAGE_CACHE_PATH @"jstx_cache/image/"
#define AUDIO_CACHE_PATH @"jstx_cache/audio/"
#define CACHE_PATH       @"jstx_cache/"
#define HTTP_CAHCE_FILE  @"jstx_cache/caches.sqlite"
//#define FASTDFS TheRuntime.msfs
//#define UPLOADURL @""
id findVlueFromNsstring(NSString* key,NSString* str);
id findVlueFromNsdic(NSString* key,NSDictionary* dic);
id findVlueFromNsarray(NSString* key,NSArray* array);
id findValueFromObject(NSString* key, id unkonwobj);
NSString* homeDirectory(){

    
    static NSString* homedictory  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);

        homedictory = [paths objectAtIndex:0];
        
    });
    return homedictory;
}
@implementation FileLoadModule{
    NSMutableDictionary* _httpfilecaches;
    FMDatabase* _database;
    FMDatabaseQueue* _dataBaseQueue;
    NSMutableDictionary* _downloadingUrls;
    NSMutableDictionary* _uploadFiles;
    AFURLSessionManager *_sessionmanager;
    dispatch_semaphore_t _uploadSig;
    dispatch_semaphore_t _downloadSig;
}



+ (instancetype)shareInstance{
    static FileLoadModule* g_contactModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_contactModule = [[FileLoadModule alloc] init];
    });
    return g_contactModule;
}
-(BOOL)createFilepathIfnotexist:(NSString*)path{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
   
    if ( !(isDir == YES && existed == YES) )
    {
        NSError* error;
        BOOL v = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(error){
            NSLog(@"error:%@",[error domain]);
            NSLog(@"error code:%ld",[error code]);
        }
        return  v;
    }
    return YES;
}
-(NSString*)LocalAudioPath:(NSString*) localpath{
    NSString* voice_cachedir = [homeDirectory() stringByAppendingPathComponent:AUDIO_CACHE_PATH];
    localpath = [voice_cachedir stringByAppendingPathComponent:localpath];
    return localpath;
}
-(NSString*)LocalImagePath:(NSString*) localpath{
    NSString* image_cachedir = [homeDirectory() stringByAppendingPathComponent:IMAGE_CACHE_PATH];
    localpath = [image_cachedir stringByAppendingPathComponent:localpath];
    return localpath;
}
-(BOOL)imageExist:(NSString*)localpath{
    NSString* url = [self LocalImagePath:localpath];
    return [self fileExist:url];
}
-(BOOL)voiceExist:(NSString*)localpath{
    NSString* url = [self LocalAudioPath:localpath];
    return [self fileExist:url];
}
-(NSString*)LocalCacheFile:(NSString*) kttpkey{
    return [_httpfilecaches objectForKey:kttpkey];
}
-(void)loadCacheDic{

    NSString* cachedir = [homeDirectory() stringByAppendingPathComponent:CACHE_PATH];
    
    
    if([self createFilepathIfnotexist:cachedir]){
        
    }
    else{
        
    }
   NSString* image_cachedir = [homeDirectory() stringByAppendingPathComponent:IMAGE_CACHE_PATH];
    if([self createFilepathIfnotexist:image_cachedir]){
        
    }
    else{
       
    }
    NSString* voice_cachedir = [homeDirectory() stringByAppendingPathComponent:AUDIO_CACHE_PATH];
    if([self createFilepathIfnotexist:voice_cachedir]){
        
    }
    else{
    }
    
    
}

#define CACHE_TABLE @"CACHE_ALLKEY"
#define CACHE_SQL @"CREATE TABLE IF NOT EXISTS %@ (httpurl text,localurl text )"

-(void)LoadCaches{
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database setShouldCacheStatements:YES];
        NSString* sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ",CACHE_TABLE];
        FMResultSet* result = [_database executeQuery:sqlString];
        while ([result next])
        {
            NSString* httpurl = [result stringForColumn:@"httpurl"];
            NSString* localurl = [result stringForColumn:@"localurl"];
            [_httpfilecaches setObject :localurl forKey:httpurl];
        }
    }];
    

}

-(void)UpdateHttpKey:(NSString*)url LocalPath:(NSString*)localpath{
      [_httpfilecaches safeSetObject:localpath forKey:url];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        [_database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            NSString* sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(?,?)",CACHE_TABLE];

            BOOL result = [_database executeUpdate:sql,url,localpath];
            if (!result)
            {
                isRollBack = YES;
            }
            
        }
        @catch (NSException *exception) {
            [_database rollback];
        }
        @finally {
            if (isRollBack)
            {
                [_database rollback];
            }
            else
            {
                [_database commit];
            }
        }
    }];
}

-(void)Cahes{
    _httpfilecaches = [NSMutableDictionary new];
    NSString* cachefile = [homeDirectory() stringByAppendingPathComponent:HTTP_CAHCE_FILE];
 
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:cachefile];
    _database = [FMDatabase databaseWithPath: cachefile];
    if (![_database open])
    {
        WDULog(@"打开数据库失败");
    }
    else
    {
        
        //创建
        [_dataBaseQueue inDatabase:^(FMDatabase *db) {
            if (![_database tableExists:@"CACHE_ALLKEY"]){
                [_database setShouldCacheStatements:YES];
                
                NSString* sql = [NSString stringWithFormat:CACHE_SQL,CACHE_TABLE];
                
                BOOL result = [_database executeUpdate:sql];
              //   [_database executeUpdate:SQL_CREATE_MESSAGE_INDEX];
               // BOOL dd =[_database executeUpdate:SQL_CREATE_CONTACTS_INDEX];
                
                NSLog(@"cache_sql:%d",result);
                
            }
        }];
    }
    
}
-(id)init{
    NSLog(@"inited");
    self = [super init];
    if(self){
        _uploadSig = dispatch_semaphore_create(1);
        _downloadSig  = dispatch_semaphore_create(1);
   
        _uploadFiles = [NSMutableDictionary new];
        _downloadQueue = dispatch_queue_create("com.bbb.www", NULL);
        _downloadingUrls = [NSMutableDictionary new];
        [self loadCacheDic];
        [self Cahes];
        [self LoadCaches];
        
        _sessionmanager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
    }
    
    return self;
}

-(NSString*)discardFileProtocol:(NSString*)path{
    if([path hasPrefix:@"file://"]){
        NSRange range ;
        range.location=7;
        range.length = path.length-7;
        return  [path substringWithRange:range];
    }
    return path;
}
-(NSString*)copyImageCompress:(NSString*)oldfullpath{
    oldfullpath = [self discardFileProtocol:oldfullpath];
    UIImage* image = [[UIImage alloc]initWithContentsOfFile:oldfullpath];
    if(image == nil) return nil;
    CGSize newSize;
    newSize.width = 200;
    newSize.height = 200;
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData* compressdata = UIImageJPEGRepresentation(newImage, 0.0);

    if(!compressdata) return nil;

    static NSInteger compressindex = 0;
    ++compressindex;
    NSString* filename = [NSString stringWithFormat:@"%f_%ld.JPG",[[NSDate date] timeIntervalSince1970],compressindex ];
    
    NSString* image_cachedir = [homeDirectory() stringByAppendingPathComponent:IMAGE_CACHE_PATH];
    NSString* nfilefullpath = [image_cachedir stringByAppendingPathComponent:filename];
    
    [compressdata writeToFile:nfilefullpath atomically:YES];
    return filename;
}
-(BOOL)copyImage:(NSString*)oldfullpath{
    oldfullpath = [self discardFileProtocol:oldfullpath];
    NSString* filename = [oldfullpath lastPathComponent];
    NSString* image_cachedir = [homeDirectory() stringByAppendingPathComponent:IMAGE_CACHE_PATH];
    NSString* nfilefullpath = [image_cachedir stringByAppendingPathComponent:filename];
    
    if([self fileExist:nfilefullpath]) return YES;

    
    UIImage* image = [[UIImage alloc]initWithContentsOfFile:oldfullpath];
    if(image == nil) return NO;
    NSData* compressdata = UIImageJPEGRepresentation(image, 0.0);
    if(compressdata == nil) return NO;
  
    BOOL ret = [compressdata writeToFile:nfilefullpath atomically:YES];
    

    return ret;
}
-(BOOL)copyVoice:(NSString*)oldfullpath{
    
    NSString* filename = [oldfullpath lastPathComponent];
    NSString* audoi_cachedir = [homeDirectory() stringByAppendingPathComponent:AUDIO_CACHE_PATH];
    NSString* nfilefullpath = [audoi_cachedir stringByAppendingPathComponent:filename];
    
    if([self fileExist:nfilefullpath]) return YES;
    
 
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error = nil;
    BOOL ret = [fm copyItemAtPath:oldfullpath toPath:nfilefullpath error:&error];
    
    if(error){
        NSLog(@"copy image faild:%@",[error domain]);
    }
    return ret;
}
-(BOOL)fileExist:(NSString*)filePath{
    NSFileManager* fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:filePath];
}
-(BOOL)deleteFile:(NSString*)filePath{
    NSString* npath = [self discardFileProtocol:filePath];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error = nil;
    return [fm removeItemAtPath:npath error:&error];
}
-(void)UpLoadImage:(NSString*) filename Block:(UploadBlock)block{
    NSString* findurl = [_httpfilecaches objectForKey:filename];
    if(findurl){
        block(findurl,nil);
        return ;
    }
    NSString* fullpath =  [self LocalImagePath:filename];
    [self UploadFile:fullpath Block:^(id respone, NSError *error) {
        if(!error){
            [self UpdateHttpKey:respone LocalPath:filename];
            [self UpdateHttpKey:filename LocalPath:respone];
        }
        block(respone,error);
    }];
}
-(void)UpLoadAudio:(NSString*) filename Block:(UploadBlock)block{
    NSString* fullpath =  [self LocalAudioPath:filename];
    [self UploadFile:fullpath Block:^(id respone, NSError *error) {
        if(!error){
            [self UpdateHttpKey:respone LocalPath:filename];
        }
        block(respone,error);
    }];
}

-(void)UploadFile:(NSString*) filePath Block:(UploadBlock)block{
}

-(void)DownLoadAudioFile:(NSString*) url   Block:(DownloadBlock)block{
    
    [self DownLoadFile:url CachePath:AUDIO_CACHE_PATH Block:block];
    
}
-(void)DownLoadImageFile:(NSString*) url   Block:(DownloadBlock)block{
    NSLog(@"img url:%@",url);
    [self DownLoadFile:url CachePath:IMAGE_CACHE_PATH Block:block];
}

-(BOOL)isValidImage:(NSString*)localpath{
    localpath = [self discardFileProtocol:localpath];
    UIImage* img = [[UIImage alloc]initWithContentsOfFile:localpath];
    return img != nil;
}
-(void)DownLoadFile:(NSString*)url CachePath:(NSString*)path Block:(DownloadBlock)block{
    
    NSString* findurl = [_httpfilecaches objectForKey:url];
    if(findurl){
        block(findurl,nil);
        return ;
    }
    
    NSMutableArray* downblocks = [_downloadingUrls objectForKey:url];
    if(downblocks){
        [downblocks addObject:block];
        return;
    }
    else {
        downblocks = [NSMutableArray new];
        [downblocks addObject:block];
        [_downloadingUrls setObject:downblocks forKey:url];
    }
    
    NSString* durlstr = nil;
    if([url hasPrefix:@"http:"] ) durlstr = url;
    
    else durlstr =  [FASTDFS stringByAppendingPathComponent:url];
    
    NSURL* durl = [NSURL URLWithString:durlstr];
    

    NSURLRequest *request = [NSURLRequest requestWithURL:durl];
    NSURLSessionDownloadTask *downloadTask = [_sessionmanager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        downloadURL = [downloadURL URLByAppendingPathComponent:path];
        downloadURL = [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        //       return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        
        //return [NSURL URLWithString:audio_file_path];
        return downloadURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {

      
            BOOL ishttp = [response isKindOfClass:[NSHTTPURLResponse class]];
            NSHTTPURLResponse* httprespone = response;
            NSLog(@"%@,%ld",response.MIMEType,[httprespone statusCode]);
            if(!error && ishttp && [httprespone statusCode] == 200){
                
                if([response.MIMEType hasPrefix:@"text"] || ([path isEqualToString:IMAGE_CACHE_PATH]&&![self isValidImage:[filePath absoluteString]])){
                    [self deleteFile:filePath.absoluteString];
                    NSError* mimetypeerror = [[NSError alloc]initWithDomain:@"error mimetype " code:0 userInfo:nil];
                    [[_downloadingUrls objectForKey:url]enumerateObjectsUsingBlock:^(DownloadBlock obj, NSUInteger idx, BOOL *stop) {
                        obj(nil,mimetypeerror);
                    }];
                    [_downloadingUrls removeObjectForKey:url];
                }
                else{
                
                    NSLog(@"File downloaded to: %@", filePath);
                    
                    NSString* filename = [filePath lastPathComponent];
                    [self UpdateHttpKey:url LocalPath:filename];
                    [[_downloadingUrls objectForKey:url]enumerateObjectsUsingBlock:^(DownloadBlock obj, NSUInteger idx, BOOL *stop) {
                        obj(filename,nil);
                    }];
                    [_downloadingUrls removeObjectForKey:url];
                }
            }
            else{
                [[_downloadingUrls objectForKey:url]enumerateObjectsUsingBlock:^(DownloadBlock obj, NSUInteger idx, BOOL *stop) {
                    obj(nil,error);
                }];
                [_downloadingUrls removeObjectForKey:url];
            }
        
        dispatch_semaphore_signal(_downloadSig);
    }];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(_downloadSig, DISPATCH_TIME_FOREVER);
        NSLog(@"start download image:%@",durl.absoluteString);
        [downloadTask resume];
    });
    
    

}

-(void)clear{
    [_downloadingUrls removeAllObjects];
    [_uploadFiles removeAllObjects];
}
@end

NSString* GetMessageResourceUpdateKey(){
    return  @"MessageResourceUpdate";
}
