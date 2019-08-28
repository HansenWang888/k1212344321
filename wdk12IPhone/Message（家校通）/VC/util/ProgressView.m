#import "ProgressView.h"


#define CLAMP(x,a,b) MIN(b,MAX(x,a))

@implementation ProgressView
{
    CGFloat _progress;
}
-(id)init{
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    
    _progress = 0;
    return self;
}
-(void)drawRect:(CGRect)rect{
    
    CGPoint center = CGPointMake(rect.origin.x+rect.size.width/2.0, rect.origin.y+rect.size.height/2.0);
        UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:40 startAngle:-M_PI_2+2*M_PI*_progress endAngle:-M_PI_2+2*M_PI clockwise:YES];
    //
        [path addLineToPoint:center];
    

    [[UIColor colorWithRed:0.64 green:0.78 blue:0.33 alpha:0.8] setFill];
    [path fill];
    
}
-(void)setProgress:(CGFloat)p{
    
    p = CLAMP(p, 0, 1);
    if(fabs(p-_progress)>0.01){
        _progress = p;
        [self setNeedsDisplay];

    }
}
@end