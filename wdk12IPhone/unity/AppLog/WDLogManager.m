//
//  WDExceptionManager.m
//  程序错误管理
//
//  Created by 老船长 on 2017/3/30.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#import "WDLogManager.h"
#import "mobilelogger.h"
#import <sys/utsname.h>
#import "RealReachability.h"
#import "WDLogBehaviorManager.h"
#import "WDSQLLogManager.h"

typedef enum {
    WDLogTypeOfException,
    WDLogTypeOfInfo,
    WDLogTypeOfLogRedirect
} WDLogType;

@interface WDLogTableVC : UITableViewController<UIDocumentInteractionControllerDelegate>
@property (nonatomic, copy) NSArray *datas;

@end

#define UserLogName @"UserLog"
#define CrashLogName @"CrashLog"

@interface WDLogManager ()
@property (nonatomic, copy) NSString *filePathURL;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileDirectory;
@property (nonatomic, weak) WDLogTableVC *showVC;
@property (assign, nonatomic) WDLogType logType;
@property (nonatomic, copy) NSString *currentUserFileName;

@end
static WDLogManager *manager = nil;
@implementation WDLogManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WDLogManager new];
    });
    return manager;
}
- (NSString *)appID {
    if (_appID.length == 0) {
        return @"";
    }
    return _appID;
}
- (NSString *)userID {
    if (_userID.length == 0) {
        return @"";
    }
    return _userID;
}
+ (void)initializeAppLog {
    [self shareManager];
    [GLobalRealReachability startNotifier];
    [self registerExceptionManager];
    [self initializeUserlog];
    [self initializebehaviorLog];
}
+ (void)registerExceptionManager {
    [self shareManager];
    NSSetUncaughtExceptionHandler(&my_uncaught_exception_handler);
}
+ (void)initializeUserlog {
    DDTTYLogger* tty = [[DDTTYLogger alloc]init];
    [DDLog addLogger:tty];
    WDEXCEPTIO_NMANAGER.logType = WDLogTypeOfInfo;
    DDLogFileManagerDefault* dm = [[DDLogFileManagerDefault alloc]initWithLogsDirectory:[NSString stringWithFormat:@"%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,UserLogName]];
    dm.maximumNumberOfLogFiles = 3;
    DDFileLogger* flogger = [[DDFileLogger alloc]initWithLogFileManager:dm];
    flogger.maximumFileSize = 1024 * 1024;
    [DDLog addLogger:flogger];
}
+ (void)initializebehaviorLog {
    [WDLogBehaviorManager logManager];
    [[WDSQLLogManager sharedSqliteManager] openBehaviorLogSQLite];
    
}

static void my_uncaught_exception_handler (NSException *exception) {
    //这里可以取到 NSException 信息
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSString *message = [NSString stringWithFormat:@"*****Time == %@*****\n  *Name == %@\n  *Reason == %@\n  *userInfo ==%@\n  *CallStackSymbols == %@\n",time,exception.name,exception.reason,exception.userInfo,exception.callStackSymbols];
    WDEXCEPTIO_NMANAGER.logType = WDLogTypeOfException;
    [WDEXCEPTIO_NMANAGER writeDataWithContent:message];
}


/*重定向不太靠谱*/
//int sfd = 0;
//int nfd = 0;
//+ (void)redirectSTD:(int )fd {
//    sfd = dup(STDERR_FILENO);
//    /*
//     通过NSPipe创建一个管道，pipe有读端和写端。
//     通过dup2将标准输入重定向到pipe的写端。
//     通过NSFileHandle监听pipe的读端，然后得到读出的信息。
//     */
//    NSPipe * pipe = [NSPipe pipe];
//    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading];
//    int fileDescriptor = [[pipe fileHandleForWriting] fileDescriptor];
//    nfd = dup2(fileDescriptor, fd);
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(redirectNotificationHandle:)
//                                                 name:NSFileHandleReadCompletionNotification
//                                               object:pipeReadHandle];
//    [pipeReadHandle readInBackgroundAndNotify];
//}
//+ (void)redirectNotificationHandle:(NSNotification *)nf {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self recoverRedirect];
//    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    [WDEXCEPTIO_NMANAGER writeDataWithContent:str];
//    [[nf object] readInBackgroundAndNotify];
//#if DEBUG
//    NSLog(@"%@",str);
//#endif
//}
////恢复重定向
//+ (void)recoverRedirect {
//    dup2(sfd, nfd);
//}
- (void)writeDataWithContent:(NSString *)content {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:WDEXCEPTIO_NMANAGER.filePathURL]) {
        NSError *error = nil;
        [content writeToFile:WDEXCEPTIO_NMANAGER.filePathURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            WDULog(@"写入错误%@",error);
        }
        return;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:WDEXCEPTIO_NMANAGER.filePathURL];
    //将节点跳到文件的末尾
    [fileHandle seekToEndOfFile];
    NSData* stringData  = [content dataUsingEncoding:NSUTF8StringEncoding];
    //追加写入数据
    [fileHandle writeData:stringData];
    [fileHandle closeFile];
}
+ (BOOL)clear {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([manager fileExistsAtPath:WDEXCEPTIO_NMANAGER.fileDirectory]) {
        if ([[manager contentsOfDirectoryAtPath:WDEXCEPTIO_NMANAGER.fileDirectory error:nil] count] > 0) {
            [manager removeItemAtPath:WDEXCEPTIO_NMANAGER.fileDirectory error:&error];
            if (error) {
                return NO;
            }
            [WDEXCEPTIO_NMANAGER.showVC setDatas:nil];
            WDEXCEPTIO_NMANAGER.currentUserFileName = @"(0)";
            return YES;
        }
    }
    return NO;
}
+ (void)rightItemBtnClick {
    [WDLogManager clear];
}
+ (void)openLogFileWithVC:(UIViewController *)vc {
    WDLogTableVC *showVC = [WDLogTableVC new];
    showVC.title = @"Log";
    WDEXCEPTIO_NMANAGER.showVC = showVC;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *urls = [manager contentsOfDirectoryAtPath:WDEXCEPTIO_NMANAGER.fileDirectory error:nil];
    NSMutableArray *datas = @[].mutableCopy;
    [urls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *arrayM = @[].mutableCopy;
        NSDictionary *dataDict = @{obj : arrayM};
        NSString *lastPath = [NSString stringWithFormat:@"%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,obj];
        NSArray *fileUrls = [manager contentsOfDirectoryAtPath:lastPath error:nil];
        [fileUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [arrayM addObject:[NSString stringWithFormat:@"%@/%@",lastPath,obj]];
        }];
        [datas addObject:dataDict];
    }];
    [showVC setDatas:datas.copy];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:showVC];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:WDEXCEPTIO_NMANAGER action:@selector(backItemCLick)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:0 target:self action:@selector(rightItemBtnClick)];
    showVC.navigationItem.rightBarButtonItem = rightItem;
    showVC.navigationItem.leftBarButtonItem = backItem;
    [vc presentViewController:navVC animated:YES completion:nil];
}
- (void)backItemCLick {
    [self.showVC dismissViewControllerAnimated:YES completion:^{
        self.showVC = nil;
    }];
}

+ (void)uploadUserLogFinished:(void (^)(BOOL))finished {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *userPath = [NSString stringWithFormat:@"%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,UserLogName];
    NSArray *urls = [manager contentsOfDirectoryAtPath:userPath error:nil];
    if (urls.count == 0 ) {
        if (finished) {
            //没有日志也提示成功
            finished(YES);
        }
        return;
    }
    Uploadendlog_InParam *param = [Uploadendlog_InParam new];
    param.m_loglist = @[].mutableCopy;
    [urls enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,obj];
        if (idx == 0 && urls.count > 3) {
            [manager removeItemAtPath:filePath error:nil];
            *stop = YES;
            return ;
        }
        Mobilelogger_Loglist_sub *sub = [self createMobileLogger];
        NSString *content = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:filePath] encoding:NSUTF8StringEncoding];
        sub.m_content = content;
        sub.m_digest = @"无";
        sub.m_type = @"2";
        [param.m_loglist addObject:sub];
    }];
    [Mobilelogger uploadendlog:param Result:^(NSError *error, Uploadendlog_OutParam *outParam) {
        if (outParam) {
            //success
            if ([outParam.m_errcode integerValue] == 0) {
                for (int i = 0; i<[outParam.m_data.m_rowcount integerValue]; ++i) {
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,urls[i]];
                    [manager removeItemAtPath:filePath error:nil];
                }
                if (finished) {
                    finished(YES);
                }
            } else {
                if (finished) {
                    finished(NO);
                }
            }
        } else {
            if (finished) {
                finished(NO);
            }
        }
    }];
}
+ (void)autoUploadUserLog {
    if (![self isWifiStatus]) return;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *userPath = [NSString stringWithFormat:@"%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,UserLogName];
    NSArray *urls = [manager contentsOfDirectoryAtPath:userPath error:nil];
    if (urls.count == 0) return;
    Uploadendlog_InParam *param = [Uploadendlog_InParam new];
    param.m_loglist = @[].mutableCopy;
    [urls enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,obj];
        if (idx == 0 && urls.count > 3) {
            [manager removeItemAtPath:filePath error:nil];
            *stop = YES;
            return ;
        }
        Mobilelogger_Loglist_sub *sub = [self createMobileLogger];
        NSString *content = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:filePath] encoding:NSUTF8StringEncoding];
        sub.m_content = content;
        sub.m_digest = @"无";
        sub.m_type = @"2";
        [param.m_loglist addObject:sub];
    }];
    [Mobilelogger uploadendlog:param Result:^(NSError *error, Uploadendlog_OutParam *outParam) {
        if (outParam) {
            //success
            if ([outParam.m_errcode integerValue] == 0) {
                for (int i = 0; i<[outParam.m_data.m_rowcount integerValue]; ++i) {
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,urls[i]];
                    [manager removeItemAtPath:filePath error:nil];
                }
            }
        }
    }];
}
+ (void)uploadExceptionLogFinished:(void (^)(BOOL))finished {
    if (![self isWifiStatus]) return;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *crashPath = [NSString stringWithFormat:@"%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,CrashLogName];
    NSArray *urls = [manager contentsOfDirectoryAtPath:crashPath error:nil];
    if (urls.count == 0) return;
    Uploadendlog_InParam *param = [Uploadendlog_InParam new];
    param.m_loglist = @[].mutableCopy;
    [urls enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0 && urls.count > 3) {
            *stop = YES;
            return ;
        }
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",crashPath,obj];
        Mobilelogger_Loglist_sub *sub = [self createMobileLogger];
        NSString *content = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:filePath] encoding:NSUTF8StringEncoding];
        sub.m_content = content;
        sub.m_digest = @"无";
        sub.m_type = @"1";
        [param.m_loglist addObject:sub];
    }];
    [Mobilelogger uploadendlog:param Result:^(NSError *error, Uploadendlog_OutParam *outParam) {
        if (outParam) {
            //success
            if ([outParam.m_errcode integerValue] == 0) {
                for (int i = 0; i<[outParam.m_data.m_rowcount integerValue]; ++i) {
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@",crashPath,urls[i]];
                    [manager removeItemAtPath:filePath error:nil];
                }
                if (finished) {
                    finished(YES);
                }
            } else {
                if (finished) {
                    finished(NO);
                }
            }
        } else {
            if (finished) {
                finished(NO);
            }
        }
    }];
}
+ (void)uploadBehaviorLogFinished:(void (^)(BOOL))finished {
    if (![self isWifiStatus]) return;
    [WDLogBehaviorManager uploadLoggerFinished:finished];
}
+ (BOOL)isCanUploadLogWithDirectory:(NSString *)derectory {
    //如果用户日志大于一兆就不进行上传
    NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:derectory error:nil];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/%@",derectory,urls[0]]];
    if (data.length > 1024 * 1024) {
        return NO;
    }
    return YES;
}
+ (BOOL)isWifiStatus {
    WWANAccessType status = [[RealReachability sharedInstance] currentWWANtype];
    return status == WWANTypeUnknown;
}
- (NSString *)filePathURL {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *currentType = nil;
    switch (self.logType) {
        case WDLogTypeOfException:
            currentType = CrashLogName;
            break;
        case WDLogTypeOfInfo:
            currentType = UserLogName;
            break;
        case WDLogTypeOfLogRedirect:
            currentType = @"LogRedirect";
            break;
        default:
            break;
    }
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",self.fileDirectory,currentType];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        //文件保护等级
        /*
         NSFileProtectionNone                                    //文件未受保护，随时可以访问 （Default）
         NSFileProtectionComplete                                //文件受到保护，而且只有在设备未被锁定时才可访问
         NSFileProtectionCompleteUntilFirstUserAuthentication    //文件收到保护，直到设备启动且用户第一次输入密码
         NSFileProtectionCompleteUnlessOpen                      //文件受到保护，而且只有在设备未被锁定时才可打开，不过即便在设备被锁定时，已经打开的文件还是可以继续使用和写入
         */
        NSDictionary *attribute = [NSDictionary dictionaryWithObject:NSFileProtectionNone
                                                              forKey:NSFileProtectionKey];
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:attribute error:nil];
    }
    _filePathURL =  [createPath stringByAppendingPathComponent:self.fileName];
    
    return _filePathURL;
}
- (NSString *)fileName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    if (self.logType == WDLogTypeOfLogRedirect) {
        _fileName = [NSString stringWithFormat:@"%@.txt",[formatter stringFromDate:[NSDate date]]];
    } else if (self.logType == WDLogTypeOfInfo) {
        _fileName = [NSString stringWithFormat:@"%@%@.txt",[formatter stringFromDate:[NSDate date]],self.currentUserFileName];
    } else if (self.logType == WDLogTypeOfException) {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *name = [formatter stringFromDate:[NSDate date]];
        _fileName = [NSString stringWithFormat:@"%@.txt",name];
    }
    return _fileName;
    
}
- (NSString *)currentUserFileName {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *urls = [manager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,UserLogName] error:nil];
    //如果文件大于三个就删除第一个
    if (urls.count > 3) {
        NSString *firstPath = [NSString stringWithFormat:@"%@/%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,UserLogName,urls[0]];
        NSError *error = nil;
        [manager removeItemAtPath:firstPath error:&error];
    }
    NSString *lastName = [urls lastObject];
    NSString *lastPath = [NSString stringWithFormat:@"%@/%@/%@",WDEXCEPTIO_NMANAGER.fileDirectory,UserLogName,lastName];
    //如果文件大于一兆 重新创建文件
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:lastPath];
    if (data.length > 1024 * 1024) {
        NSString *lastSecond = [lastName substringWithRange:NSMakeRange(lastName.length - 6, 1)];
        _currentUserFileName = [NSString stringWithFormat:@"(%d)",[lastSecond integerValue] + 1];
    } else if(data.length > 0) {
        _currentUserFileName = [NSString stringWithFormat:@"(%@)",[lastName substringWithRange:NSMakeRange(lastName.length - 6, 1)]];
    }
    if (urls.count == 0) {
        _currentUserFileName = @"(0)";
    }
    return _currentUserFileName;
}
- (NSString *)fileDirectory {
    if (!_fileDirectory) {
        NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        _fileDirectory = [NSString stringWithFormat:@"%@/WDLog", pathDocuments];
    }
    return _fileDirectory;
    
}

#pragma mark - 重定向nslog
// 将NSlog打印信息保存到Document目录下的文件中,没有用到
+ (void)registerLogRedirectInFile {
    WDEXCEPTIO_NMANAGER.logType = WDLogTypeOfLogRedirect;
    //     stdin、stdout 和 stderr
    //stdout（标准输出流）的目的地是显示器，printf()是将流中的内容输出到显示器
    //stdin是标准输入，一般指键盘输入到缓冲区里的东西。
    //stderr 标准输出(设备)文件，对应终端的屏幕。进程将从标准输入文件中得到输入数据，将正常输出数据输出到标准输出文件，而将错误信息送到标准错误文件中。在C中，程序执行时，一直处于开启状态。
    // 将log输入到文件
    freopen([WDEXCEPTIO_NMANAGER.filePathURL cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([WDEXCEPTIO_NMANAGER.filePathURL cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (Mobilelogger_Loglist_sub *)createMobileLogger {
    Mobilelogger_Loglist_sub *sub = [Mobilelogger_Loglist_sub new];
    sub.m_appid = APPID_log;
    sub.m_appversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    sub.m_recorder = @"iOS";
    sub.m_end = [self iphoneType];
    sub.m_endinfo = @"None";
    sub.m_endos = [UIDevice currentDevice].systemVersion;
    sub.m_endlogtime = [NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSince1970 * 1000];
    return sub;
}
+ (NSString *)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}
@end

#pragma mark - 查看log控制器
@interface WDLogTableVC ()
@property (nonatomic, strong) NSMutableArray<NSMutableString *> *sectionStretchArray;

@end
@implementation WDLogTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"logCell"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];
}
- (void)setDatas:(NSArray *)datas {
    self.sectionStretchArray = @[].mutableCopy;
    [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.sectionStretchArray addObject:@"1".mutableCopy];
    }];
    _datas = datas;
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _datas.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [self.datas[section] allValues][0];
    BOOL isStretch = [self.sectionStretchArray[section] boolValue];
    if (isStretch) {
        return array.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logCell" forIndexPath:indexPath];
    NSArray *array = [self.datas[indexPath.section] allValues][0];
    NSString *fileName = [array[indexPath.row] lastPathComponent];
    cell.textLabel.text = fileName;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [self.datas[indexPath.section] allValues][0];
    NSURL* url = [NSURL fileURLWithPath:array[indexPath.row]];
    NSString *fileName = [array[indexPath.row] lastPathComponent];
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    documentController.delegate = self;
    documentController.name = fileName;
    BOOL isOpen = [documentController presentPreviewAnimated:NO];
    if (isOpen == NO) {
        
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    UIButton *btn = [view viewWithTag:999];
    if (!btn) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.textColor = btn.backgroundColor;
        btn.frame  = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        [btn addTarget:self action:@selector(headerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [view.contentView addSubview:btn];
        btn.selected = YES;
    }
    [btn setTitle:[NSString stringWithFormat:@"%ld",section] forState:UIControlStateNormal];
    NSString *key = [self.datas[section] allKeys][0];
    view.textLabel.text = key;
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
- (void)headerBtnClick:(UIButton *)btn {
    NSInteger section = [btn.titleLabel.text integerValue];
    NSMutableString *stretch = self.sectionStretchArray[section];
    if (stretch.boolValue) {
        stretch.string = @"0";
    } else {
        stretch.string = @"1";
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[btn.titleLabel.text integerValue]] withRowAnimation:0];
}
#pragma mark - documentDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    
}
- (void)dealloc {
    
}
@end

