//
//  RCCtrl.m
//  wdk12pad
//
//  Created by macapp on 15/12/30.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import "RCCtrl.h"
#import "RCDocCtrl.h"
#import "RCVideoCtrl.h"
#import "RCAudioCtrl.h"
#import "RCUnKnownCtrl.h"
#import "RCImageCtrl.h"
#import "RCTxtCtrl.h"

typedef NS_ENUM(NSInteger,ResourceType) {
    ResourceTypeUnknow = 0,
    ResourceTypeVideoStream,
    ResourceTypeAudioStream,
    ResourceTypeTxt,
    ResourceTypeDoc,
    ResourceTypeImg
};

@implementation RCCtrl
+(NSMutableDictionary*)ResourceMap{
    static NSMutableDictionary* _resourceMap = nil;
    if(_resourceMap == nil){
        _resourceMap = [NSMutableDictionary new];
        [_resourceMap setObject:@(ResourceTypeVideoStream) forKey:@"FLV"];
        [_resourceMap setObject:@(ResourceTypeVideoStream) forKey:@"AVI"];
        [_resourceMap setObject:@(ResourceTypeVideoStream) forKey:@"MP4"];
        [_resourceMap setObject:@(ResourceTypeVideoStream) forKey:@"RMVB"];
        [_resourceMap setObject:@(ResourceTypeAudioStream) forKey:@"WMA"];
        [_resourceMap setObject:@(ResourceTypeAudioStream) forKey:@"WAV"];
        [_resourceMap setObject:@(ResourceTypeAudioStream) forKey:@"MP3"];
        [_resourceMap setObject:@(ResourceTypeAudioStream) forKey:@"AMR"];
        [_resourceMap setObject:@(ResourceTypeAudioStream) forKey:@"CAF"];

        
        [_resourceMap setObject:@(ResourceTypeDoc) forKey:@"DOC"];
        [_resourceMap setObject:@(ResourceTypeDoc) forKey:@"DOCX"];
        [_resourceMap setObject:@(ResourceTypeDoc) forKey:@"PPT"];
        [_resourceMap setObject:@(ResourceTypeDoc) forKey:@"PPTX"];
        [_resourceMap setObject:@(ResourceTypeDoc) forKey:@"PDF"];
        [_resourceMap setObject:@(ResourceTypeDoc) forKey:@"XLSX"];
        [_resourceMap setObject:@(ResourceTypeDoc) forKey:@"XLS"];
        
        [_resourceMap setObject:@(ResourceTypeTxt) forKey:@"TXT"];
        
        [_resourceMap setObject:@(ResourceTypeImg) forKey:@"PNG"];
        [_resourceMap setObject:@(ResourceTypeImg) forKey:@"JPG"];
        [_resourceMap setObject:@(ResourceTypeImg) forKey:@"GIF"];
        [_resourceMap setObject:@(ResourceTypeImg) forKey:@"JPEG"];
        
    }
    return _resourceMap;
}
+(id)initWithPath:(NSString*)path ConverPath:(NSString*)converpath Type:(NSString*)type Name:(NSString*)name VC:(ResourceVCViewController*)vc{
    
    ResourceType rctype= [[[RCCtrl ResourceMap]objectForKey:type] integerValue];
    
    RCCtrl* ret = nil;
    if(rctype == ResourceTypeAudioStream){
        ret = [[RCVideoCtrl alloc]initWithVC:vc Path:converpath];
    }
    if(rctype == ResourceTypeVideoStream){
        ret = [[RCVideoCtrl alloc]initWithVC:vc Path:converpath];
    }
    if(rctype == ResourceTypeDoc){
        ret = [[RCDocCtrl alloc] initWithVC:vc Path:path];
    }
    if (rctype == ResourceTypeImg) {
        ret = [[RCImageCtrl alloc] initWithVC:vc Path:path];
    }
    if (rctype == ResourceTypeTxt) {
        ret = [[RCTxtCtrl alloc] initWithVC:vc Path:path];
    }
    
    if ([type isEqualToString:@"BMP"] || [type isEqualToString:@"bmp"]) {
        ret = [[RCImageCtrl alloc] initWithVC:vc Path:converpath];
    }
    
    if(ret == nil) ret = [[RCUnKnownCtrl alloc]initWithVC:vc Path:path];
    ret.name = name;
    return ret;
}
-(id)initWithVC:(ResourceVCViewController*)vc Path:(NSString*)path{
    self = [super init];
    _vc = vc;
    _path = path;
    return self;
}

-(void)start{
    
}
-(void)end{
    
}
@end
