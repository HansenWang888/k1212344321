//
//  ChatAnthorView.m
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "ChatAnthorView.h"
#import "ChatMarcos.h"
#import "SDWebImageManager.h"
#import "UIImage+FullScreen.h"
#import "FileModule.h"
#import "ProgressView.h"
#import "PlayerManager.h"
@interface FlyFullScreenAnchorMaskView:FlyFullScreenMaskView

@property ChatAnthorView* origin;

@end

@implementation FlyFullScreenAnchorMaskView
-(void)start{
    _origin.hidden = YES;
}
-(void)end{
    _origin.hidden = NO;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    return self;
}
@end



@interface PlayerMangerDelegateSingleton : NSObject<PlayingDelegate>

+(instancetype)shareDelegate;

-(void)addChatVoiceView:(ChatAnthorView*)view;
-(void)removeChatVoiceView:(ChatAnthorView*)view;
@end

@interface ChatAnthorView(){
    
    
@protected
    
    UITapGestureRecognizer* _tapgesture;
    ProgressView*         _progressView;
    
    
    NSString* _voicePath;
    NSString* _localVoicePath;
    
    NSTimeInterval   _voicelength;
    BOOL      _isHttpVoice;
    NSString* _text;
    NSString* _imageurl;
    UIImage* _image;
    DRC rc;
    AnchorForward _anchorForward;
    CGFloat _th;
    CGFloat _start;
    CGFloat _end;
    CGFloat _anthor;
    CGFloat _lmargin;
    CGFloat _rmargin;
    
    NSInteger _framecount;
    CGFloat _r;
    CGFloat _b;
    CGFloat _g;
    CGFloat _a;
    
    CGFloat _VolemeClass;
    
    //anchor
    CGPoint p1;
    CGPoint p2 ;
    CGPoint p12;
    CGPoint p3;
    CGPoint p4;
    CGPoint p34 ;
    CGPoint p5;
    CGPoint p6 ;
    CGPoint p56;
    CGPoint p7 ;
    CGPoint p8 ;
    CGPoint p78 ;
}
@end

@implementation ChatAnthorView
{
    CADisplayLink* _blinkTimmer;
    CADisplayLink* _voicePlayerTimmer;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    _th = 5.0;
    _r = 0.64 ;
    _g = 0.78;
    _b=0.33 ;
    _a = 1;
    _VolemeClass = 3;
   // ++ccc;
   // NSLog(@"alloc ccc:%d,:%p",ccc,self);
}
-(void)dealloc{
    [self stopBlink];
    [self stopPlayVoice];
    [self onDisappera];
   
  //  --ccc;
  //  NSLog(@"dealloc ccc:%d",ccc);
}


-(void)setText:(NSString*)text{
    _text = text;
    [self setNeedsDisplay];
    
}
-(BOOL)setImageUrl:(NSString*)url_str{
    
//    if([url_str isEqualToString:_imageurl]) return YES;
//    else{
//        [self onDisappera];
//    }
    _image = nil;
    _imageurl = url_str;
    NSURL* url_abs = [NSURL URLWithString:[NSString stringWithFormat:@"%@_abs",url_str]];
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    
    NSString* cache_key = [manager cacheKeyForURL:url_abs];
    
    do{
        
        [_progressView setHidden: YES];
        _image = [manager.imageCache imageFromMemoryCacheForKey:cache_key];
        if(_image){
            [self setNeedsDisplay];
            break;
        }
        else _image = [manager.imageCache imageFromDiskCacheForKey:cache_key];
        if(_image){
            [self setNeedsDisplay];
            break;
        }
        
        [_progressView setHidden:NO];
        [[FileModule shareInstance]downLoadImage:url_str Delegate:self];
        
        [self setNeedsDisplay];
        
    }while(0);
    

    
    if(!_tapgesture){
        self.userInteractionEnabled = YES;
        _tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:_tapgesture];
    }
    
    return _image != nil;
}

-(void)setAudioAndLength:(NSString*)filepath IsHttp:(BOOL)ishttp{
    [[PlayerMangerDelegateSingleton shareDelegate]addChatVoiceView:self];
//    if([_voicePath isEqualToString: filepath]) return;
//    else{
//        [self onDisappera];
//    }
    _voicePath = nil;
    _voicePath = filepath;
    _isHttpVoice = ishttp;
    

    
    
    
    if(_voicePath){
        if(!_tapgesture){
            self.userInteractionEnabled = YES;
            _tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onVoiceTap)];
            [self addGestureRecognizer:_tapgesture];
        }
    }
    //http part
    if(_isHttpVoice){
        
        NSString* filename = [filepath lastPathComponent];
        if(![[FileModule shareInstance]isLocalVoiceFileExist:filename]){
            [[FileModule shareInstance]downLoadVoice:_voicePath Delegate:self];
            _r = _g =_b = 0.5;
            _a = 1.0;
        }
        else{
            _r = _g =_b = 1.0;
            _a = 1.0;
        }
    }
    else{
        if(!_voicePath) {
            _voicePath = @"";
        }
    }
    
    if(filepath){
        NSString* filename = [filepath lastPathComponent];
        NSString* localfilepath = [[FileModule shareInstance]getLocalVoiceFilePath:filename];
        
        if([[PlayerManager sharedManager]playingFileName:localfilepath]){
            [self startPlayVoice];
        }
        else{
            [self stopPlayVoice];
        }
    }
    else{
        [self stopPlayVoice];
    }
    
}

-(void)onReciveData:(long long)recivedSize Expect:(long long)expectSize{
    
}
-(void)Compeletion:(BOOL )finished{
}


-(void)startPlayVoice{
    if(_voicePlayerTimmer) return;
    _voicePlayerTimmer = [CADisplayLink displayLinkWithTarget:self selector:@selector(onPlayer:)];
    
    [_voicePlayerTimmer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _VolemeClass = 0;
 //   NSLog(@"call start");
    [self setNeedsDisplay];
    
}
-(void)stopPlayVoice{
    if(_voicePlayerTimmer){
        [_voicePlayerTimmer invalidate];
        _voicePlayerTimmer = nil;
        _VolemeClass = 3;
  //      NSLog(@"call stop");
        [self setNeedsDisplay];
    }
}
-(void)onPlayer:(CADisplayLink*) timmer{
    NSInteger before = round(_VolemeClass);
    _VolemeClass += 2*timmer.duration;
    if(_VolemeClass > 3) _VolemeClass = 0;
    NSInteger after = round(_VolemeClass);
    if(before != after) [self setNeedsDisplay];
}
-(void)onVoiceTap{
    if(_voicePath== nil || [  _voicePath isEqualToString:@""]) return;
    NSString* localPath = nil;
    

    NSString* filename = [_voicePath lastPathComponent];
    if([[FileModule shareInstance]isLocalVoiceFileExist:filename]){
        localPath = [[FileModule shareInstance]getLocalVoiceFilePath:filename];
    }
    
    
    if(!localPath) return;
    if([[PlayerManager sharedManager]playingFileName:localPath]) {
        
        [[PlayerManager sharedManager]stopPlaying];
        
    }
    //NSLog(@"%@",localPath);
    else{
        [self startPlayVoice];

        [[PlayerManager sharedManager]playAudioWithFileName:localPath delegate:[PlayerMangerDelegateSingleton shareDelegate]];
    }
    
}


-(void)onTap{
    UIImage* fullimage = nil;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    NSString* cache_key = [manager cacheKeyForURL:[NSURL URLWithString:_imageurl]];
    do{
        fullimage = [manager.imageCache imageFromMemoryCacheForKey:cache_key];
        if(fullimage) break;
        fullimage = [manager.imageCache imageFromDiskCacheForKey:cache_key];
    }while(0);
    
    
    
    if(fullimage){
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        CGRect maskframe = CGRectMake(rc.x, rc.y, rc.w, rc.h);
        frame = [self convertRect:frame toView:nil];
        
        FlyFullScreenAnchorMaskView* maskview = [[FlyFullScreenAnchorMaskView alloc]initWithFrame:maskframe];
        [maskview setOrigin:self];
        [UIImage FlyFullScreenWithView:fullimage OriginRect:frame MaskView:maskview];
        
    }
    
}
-(void)reRect:(CGRect)rect{
    rc.x = _lmargin;
    rc.y = 0;
    rc.w = rect.size.width - _lmargin - _rmargin;
    rc.h = rect.size.height;
    rc.r = 5;
    rc.ml = _lmargin;
    rc.mr = _rmargin;
    rc.mb = 0;
    rc.mt = 0;
    
    
    p1 = Getp1(&rc);
    p2 = Getp2(&rc);
    p12 = Getp12(&rc);
    p3 = Getp3(&rc);
    p4 = Getp4(&rc);
    p34 = Getp34(&rc);
    p5 = Getp5(&rc);
    p6 = Getp6(&rc);
    p56 = Getp56(&rc);
    p7 = Getp7(&rc);
    p8 = Getp8(&rc);
    p78 = Getp78(&rc);
}



//157 199 85
- (void)drawRect:(CGRect)rect {
    [self reRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, _r,_g,_b,_a);
    
    CGContextMoveToPoint(context, p1.x, p1.y);
    

    
    CGContextAddArcToPoint(context, p12.x, p12.y, p2.x, p2.y, rc.r);

    if(_anchorForward == AnchorForwardTop){
        CGPoint ps,pa,pe;
        GetPoints(&rc, _start, _end, _anthor, _anchorForward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
    }
    else{
        CGContextAddLineToPoint(context, p3.x, p3.y);
        
    }
 //   goto enddraw;
    
    CGContextAddArcToPoint(context, p34.x, p34.y, p4.x, p4.y, rc.r);
    if(_anchorForward == AnchorForwardRight){
        CGPoint ps,pa,pe;
        GetPoints(&rc, _start, _end, _anthor, _anchorForward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
    }
    else{
        CGContextAddLineToPoint(context, p5.x, p5.y);
    }
    
    
    CGContextAddArcToPoint(context, p56.x, p56.y, p6.x, p6.y, rc.r);
    if(_anchorForward == AnchorForwardBottom){
        CGPoint ps,pa,pe;
        GetPoints(&rc, _start, _end, _anthor, _anchorForward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
    }
    else{
        CGContextAddLineToPoint(context, p7.x, p7.y);
    }
    
    
    CGContextAddArcToPoint(context, p78.x, p78.y, p8.x, p8.y, rc.r);
    if(_anchorForward == AnchorForwardLeft){
        CGPoint ps,pa,pe;
        GetPoints(&rc, _start, _end, _anthor, _anchorForward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
        
        
    }
    else{
        CGContextAddLineToPoint(context, p1.x, p1.y);
    }

    
    CGContextClosePath(context);
    CGContextSetRGBStrokeColor(context, 0.667, 0.667, 0.667, 1);
    CGContextSetLineWidth(context, 0.5);
    if(_text){
        CGContextDrawPath(context, kCGPathFillStroke);
        [_text drawInRect:CGRectMake(rc.x+TEXT_MARGIN, rc.y+TEXT_MARGIN, rc.w-2*TEXT_MARGIN, rc.h) withAttributes:FONT_ATTRIBUTE];
    }
    if(_voicePath){
        CGContextSetLineWidth(context, 1.0);
        CGContextDrawPath(context, kCGPathFillStroke);
        NSInteger k = round(_VolemeClass);
        if(_lmargin == 0){
            CGFloat x = rc.w-5;
            CGFloat y = rc.h/2.0;
            CGFloat fy = -0.707;
            for(NSInteger i = 0 ; i < k;++i){
                
                CGContextAddArc(context, x, y, 6*(i+1), fy+M_PI, -fy+M_PI, 0);
                CGContextStrokePath(context);
                
            }
        }
        else{
            CGFloat x = rc.x+5;
            CGFloat y = rc.h/2.0;
            CGFloat fy = -0.707;
            for(NSInteger i = 0 ; i < k;++i){
                
                CGContextAddArc(context, x, y, 6*(i+1), fy, -fy, 0);
                CGContextStrokePath(context);
                
            }
        }
        
        
        
        
        
        
    }
    if(_image) {
        CGContextClip(context);
        [_image drawInRect:rect];
    }
    if(_image == nil && _imageurl){
        CGContextSetRGBFillColor(context, 1,1,1,1);
        CGContextDrawPath(context, kCGPathFill);
    }
}
-(void)startBlink{
    if(_blinkTimmer) return;
    _blinkTimmer = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimmer:)];
    
    [_blinkTimmer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _framecount = 0;
    _VolemeClass = 0;
}
-(void)onTimmer:(CADisplayLink*)timmer{
    _framecount++;
    if((_framecount/60)%2 !=0){
        _a =0.4+ 0.01*(_framecount%60);
    }
    else{
        _a = 1- 0.01*(_framecount%60);
    }
    [self setNeedsDisplay];
}
-(void)stopBlink{
    if(_blinkTimmer){
        [_blinkTimmer invalidate];
        _blinkTimmer = nil;
        
        _a = 1;
        _VolemeClass = 3.0;
    }
}

-(void)onDisappera{
    if(_imageurl ){
        [[FileModule shareInstance]removeDelegate:self StringUrl:_imageurl];
        if(_progressView) [_progressView setHidden:YES];
    }
    if(_voicePath){
        [[FileModule shareInstance]removeDelegate:self StringUrl:_voicePath];
    }
    [self stopPlayVoice];
    [self stopBlink];
    [[PlayerMangerDelegateSingleton shareDelegate]removeChatVoiceView:self];
}

@end


@implementation ChatAnthorViewLeft
-(void)awakeFromNib{
    [super awakeFromNib];
    _th = 5.0;
    _r = 1;
    _g = 1;
    _b= 1;
    _a = 1;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    _anchorForward = AnchorForwardLeft;
    _lmargin = ANCHOR_MARGIN;
    
    [self reRect:self.frame];
    
    _anthor =  IMAGE_HEIGHT/2/rc.h;
    CGFloat ah = ANCHOR_HEIGTH/rc.h;
    
    _end = _anthor - ah/2.0;
    _start = _anthor + ah/2.0;
    
    [self setNeedsDisplay];
}

@end

@implementation ChatAnthorViewRight

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    _anchorForward = AnchorForwardRight;
    _rmargin = ANCHOR_MARGIN;
    
    [self reRect:self.frame];
    
    _anthor = IMAGE_HEIGHT/2/rc.h;
    
    CGFloat ah = ANCHOR_HEIGTH/rc.h;
    
    _start = _anthor - ah/2.0;
    _end = _anthor + ah/2.0;
    
    [self setNeedsDisplay];
}

@end

@implementation chatAnthorImageViewLeft


-(void)awakeFromNib{
    [super awakeFromNib];
    _progressView = [[ProgressView alloc]init];
    [self addSubview:_progressView];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _progressView.frame = CGRectMake(_lmargin, 0, self.frame.size.width-_lmargin, self.frame.size.height);
    [_progressView setNeedsDisplay];
}
-(void)onReciveData:(long long)recivedSize Expect:(long long)expectSize{
    float x = (float)(recivedSize)/(float)(expectSize);
    [_progressView setProgress:x];
}
-(void)Compeletion:(BOOL)finished{
    if(_imageurl && finished){
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        NSURL* url_abs = [NSURL URLWithString:[NSString stringWithFormat:@"%@_abs",_imageurl]];
        NSString* cache_key = [manager cacheKeyForURL:url_abs];
        _image = [manager.imageCache imageFromDiskCacheForKey:cache_key];
        if(_image) {
            [self setNeedsDisplay];
            [_progressView setHidden:YES];
        }
    }
    else{
        NSLog(@"other error");
    }
}
@end

@implementation chatAnthorVoiceViewLeft
-(void)onReciveData:(long long)recivedSize Expect:(long long)expectSize{
    //NSLog(@"%lld,%lld",recivedSize,expectSize);
}

-(void)Compeletion:(BOOL)finished{
    if(finished){
        _th = 5.0;
        _r = 1 ;
        _g = 1;
        _b= 1;
        _a = 1;
        [self setNeedsDisplay];
    }
}

@end

//@implementation chatAnthorVoiceViewRight
//
//
//
//@end

@implementation PlayerMangerDelegateSingleton
{
    NSMutableArray<ChatAnthorView*>* _voiceViews;
}
+(instancetype)shareDelegate{
    static PlayerMangerDelegateSingleton* g_Module;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_Module = [[PlayerMangerDelegateSingleton alloc] init];
    });
    return g_Module;
}
-(id)init{
    self = [super init];
    _voiceViews = [NSMutableArray new];
    return self;
}
-(void)addChatVoiceView:(ChatAnthorView*)view{
    if([_voiceViews containsObject:view]) return;
    [_voiceViews addObject:view];
}
-(void)removeChatVoiceView:(ChatAnthorView*)view{
    
    if([_voiceViews containsObject:view]){
        [_voiceViews removeObject:view];
      
    }
}
-(void)playingStoped{
    [_voiceViews enumerateObjectsUsingBlock:^(ChatAnthorView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj stopPlayVoice];
    }];
}

@end
