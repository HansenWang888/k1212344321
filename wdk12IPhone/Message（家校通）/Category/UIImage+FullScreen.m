#import "UIImage+FullScreen.h"


const CGFloat FlyFullScreenTime = 0.25;
#define COLOR_URGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0]
@interface FlyFullScrren : NSObject

+(instancetype)ShareInstace;

@end
static const short LINEAR_IN = 1;
static const short LINEAR_OUT = 2;
@implementation FlyFullScrren
{
    UIView* _bgview;
    UIView* _curtop;
    CGRect _originFrame;
    CGRect _maskFrame;

    NSMutableArray<NSLayoutConstraint*>* _CSS;
    CADisplayLink* _alphaLinearTimmer;
    short _linearMode;
    CGFloat _timmertime;
    
    FlyFullScreenMaskView* _maskView;
}
+(instancetype)ShareInstace{
    static FlyFullScrren* g_ins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_ins = [[FlyFullScrren alloc]init];
    });
    return g_ins;
}
-(id)init{
    self = [super init];
    _bgview = [[UIView alloc]initWithFrame:[[UIApplication sharedApplication].keyWindow bounds]];
    _bgview.hidden = YES;
    
    _bgview.backgroundColor = [UIColor clearColor];

    [[UIApplication sharedApplication].keyWindow addSubview:_bgview];
    
    _CSS = [NSMutableArray new];
    
    return self;
}

-(void)FlyFullScreen:(UIImage*)origin OriginRect:(CGRect)rect MaskRect:(CGRect)maskrect MaskView:(FlyFullScreenMaskView*)maskview{
    if(_curtop != nil) return;
    if(_alphaLinearTimmer != nil) return;
    UIImageView* imageview = [[UIImageView alloc]init];
    imageview.image = origin;
    imageview.backgroundColor = [UIColor clearColor];
    imageview.userInteractionEnabled = YES;
    imageview.frame = rect;
    _curtop = imageview;
    _originFrame = rect;
   
    if(!maskview){
        maskview = [[FlyFullScreenMaskView alloc]init];
        maskview.backgroundColor = [UIColor colorWithWhite:0 alpha:1];;
        maskview.frame = maskrect;
        _maskFrame = maskrect;
    }
    else{
        _maskFrame = maskview.frame;
    }
    
    [imageview addSubview:maskview];
    imageview.maskView = maskview;
    _maskView = maskview;
    CGFloat aspectradio = origin.size.height/origin.size.width;
    [_bgview addSubview:imageview];
    _bgview.hidden = NO;
    
    
    CGFloat width = _bgview.frame.size.width;
    CGFloat height = aspectradio*width;
    
    CGFloat ox = 0;
  //  _bgview.backgroundColor = [UIColor blackColor];
  //  imageview.alpha = 0;
   // return;
    _linearMode = LINEAR_IN;
    _timmertime = 0;
    _alphaLinearTimmer = [CADisplayLink displayLinkWithTarget:self selector:@selector(onAlphaLinear:)];
    [_alphaLinearTimmer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_maskView start];
    
    CGFloat oy =  (_bgview.frame.size.height-height)/2.0;
    [UIView animateWithDuration:FlyFullScreenTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [imageview setFrame:CGRectMake(ox, oy, width, height)];
        [maskview setFrame:CGRectMake(0, 0, width, height)];
        _bgview.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        imageview.layer.cornerRadius = 0.0;
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap)];
        [_bgview addGestureRecognizer:gesture];
        
        [_alphaLinearTimmer invalidate];
        _alphaLinearTimmer = nil;
        [_maskView setLinear:1];
    }];
}
-(void)onAlphaLinear:(CADisplayLink*)timmer{
    _timmertime += timmer.duration;
    CGFloat linear = _timmertime/FlyFullScreenTime;
    linear = MIN(1, MAX(linear, 0));
    if(_linearMode == LINEAR_IN){
    
    }
    else{
        linear = 1-linear;
    }

    [_maskView setLinear:linear];
}
-(void)onTap{
    if(_curtop){
        _linearMode = LINEAR_OUT;
        _timmertime = 0;
        _alphaLinearTimmer = [CADisplayLink displayLinkWithTarget:self selector:@selector(onAlphaLinear:)];
        [_alphaLinearTimmer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [UIView animateWithDuration:FlyFullScreenTime animations:^{
            _curtop.frame = _originFrame;
            _curtop.maskView.frame = _maskFrame;
            _bgview.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            _bgview.hidden = YES;
            [_curtop removeFromSuperview];

            [[_bgview gestureRecognizers] enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [_bgview removeGestureRecognizer:obj];
            }];
            
            [_alphaLinearTimmer invalidate];
            _alphaLinearTimmer = nil;
            [_maskView setLinear:0];
            [_maskView end];
            _maskView = nil;
            _curtop = nil;
        
        }];

    }
}

@end

@implementation FlyFullScreenMaskView
-(void)start{
    
}
-(void)end{
    
}
@end

@implementation UIImage(FlyFullScreen)
+(void)FlyFullScreenWithMask:(UIImage*)origin OringinRect:(CGRect)rect MaskRect:(CGRect)maskrect{
    [[FlyFullScrren ShareInstace]FlyFullScreen:origin OriginRect:rect MaskRect:maskrect MaskView:nil];
}
+(void)FlyFullScreenWithView:(UIImage*)origin OriginRect:(CGRect)rect
                        MaskView:(UIView*)maskView{
    [[FlyFullScrren ShareInstace]FlyFullScreen:origin OriginRect:rect MaskRect:CGRectZero MaskView:maskView];
}
+(void)FlyFullScreen:(UIImage*)origin OriginRect:(CGRect)rect{

    
    [[FlyFullScrren ShareInstace]FlyFullScreen:origin OriginRect:rect MaskRect:CGRectMake(0, 0, origin.size.width, origin.size.height) MaskView:nil];
    
}
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
@end

@implementation UIImage(PureColor)
+(UIImage*)pureColorImage:(UIColor*)color ForSize:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
}
+(UIImage*)redImage{
    static UIImage* _red= nil;
     static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _red = [UIImage pureColorImage:[UIColor redColor] ForSize:CGSizeMake(4, 4)];
    });
    return _red;
}
+(UIImage*)darkRedImage{
    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _red = [UIImage pureColorImage:[UIColor colorWithRed:0.7 green:0 blue:0 alpha:0] ForSize:CGSizeMake(4, 4)];
    });
    return _red;
}
+(UIImage*)wdSysImage{
    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _red = [UIImage pureColorImage:COLOR_URGBA(0x3D, 0xA9, 0x9D, 255) ForSize:CGSizeMake(4, 4)];
    });
    return _red;
}
+(UIImage*)wdDarkSysImage{
    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _red = [UIImage pureColorImage:COLOR_URGBA(0x30, 0xA0, 0x90, 255) ForSize:CGSizeMake(4, 4)];
    });
    return _red;
}
+(UIImage*)whiteImage{
    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _red = [UIImage pureColorImage:COLOR_URGBA(0xFF, 0xFF, 0xFF, 255) ForSize:CGSizeMake(4, 4)];
    });
    return _red;
}
+(UIImage*)lightGrayImage{
    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _red = [UIImage pureColorImage:COLOR_URGBA(0xcc, 0xcc, 0xcc, 255) ForSize:CGSizeMake(4, 4)];
    });
    return _red;
}
+ (UIImage *)IMThemeColorImage {
    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        _red = [UIImage pureColorImage:COLOR_URGBA(91, 97, 105, 255) ForSize:CGSizeMake(4, 29)];
        _red = [UIImage pureColorImage:COLOR_URGBA(49, 58, 67, 255) ForSize:CGSizeMake(4, 29)];

    });
    return _red;
}
+ (UIImage *)IMSearchBarSearchColorImage {

    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        _red = [UIImage pureColorImage:COLOR_URGBA(91, 97, 105, 255) ForSize:CGSizeMake(4, 29)];
        _red = [UIImage pureColorImage:COLOR_URGBA(91, 97, 105, 255) ForSize:CGSizeMake(4, 29)];
    });
    return _red;

}
+ (UIImage *)IMNavBarColorImage {
    static UIImage* _red= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _red = [UIImage pureColorImage:COLOR_URGBA(249, 249, 249, 255) ForSize:CGSizeMake(4, 1)];
    });
    return _red;
}
@end
