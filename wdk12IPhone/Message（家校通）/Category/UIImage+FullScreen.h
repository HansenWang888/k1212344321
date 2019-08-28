#import <UIKit/UIKit.h>

extern const CGFloat FlyFullScreenTime ;

@interface FlyFullScreenMaskView : UIView
@property(nonatomic) CGFloat linear;
-(void)start;
-(void)end;
@end


@interface UIImage(FlyFullScreen)

+(void)FlyFullScreen:(UIImage*)origin OriginRect:(CGRect)rect;
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+(void)FlyFullScreenWithMask:(UIImage*)origin OringinRect:(CGRect)rect MaskRect:(CGRect)maskrect;
+(void)FlyFullScreenWithView:(UIImage*)origin OriginRect:(CGRect)rect
    MaskView:(FlyFullScreenMaskView*)maskView;
@end


@interface UIImage(PureColor)
+(UIImage*)pureColorImage:(UIColor*)color ForSize:(CGSize)size;
+(UIImage*)redImage;
+(UIImage*)darkRedImage;

+(UIImage*)wdSysImage;
+(UIImage*)wdDarkSysImage;

+(UIImage*)whiteImage;
+(UIImage*)lightGrayImage;
+(UIImage *)IMThemeColorImage;//即使通讯主题颜色图片
+(UIImage *)IMNavBarColorImage;//即使通讯detail NavBar颜色图片
+ (UIImage *)IMSearchBarSearchColorImage;//即时通讯搜索栏里搜索框的颜色
@end

void ImageFlyFullScreen(UIImage* image,CGRect originrect);