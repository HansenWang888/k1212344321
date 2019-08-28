
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,BorderPosition){
    BorderPositionLeft=1,
    BorderPositionRight=2,
    BorderPositionTop=4,
    BorderPositionBottom=8
};

@interface BorderedView : UIView

@property BorderPosition borderPosition;

@end