//
#import <UIKit/UIKit.h>

@interface WDSegmentView : UIView

-(id)initWithTitles:(NSArray<NSString*>*)titles SliderLineHeihgt:(CGFloat)sliderLineHeight;

-(void)setFont:(UIFont*)font;

-(void)setSelectWithIndex:(NSInteger)index Animated:(BOOL)animated;
-(void)setNormalTextColor:(UIColor*) color;
-(void)setSelectedTextColor:(UIColor*) color;
-(NSInteger)getSelectIndex;

-(void)setTarget:(id)target Action:(SEL)action;
-(void)doModal;
@end