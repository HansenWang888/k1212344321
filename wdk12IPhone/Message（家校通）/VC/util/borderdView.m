#import "borderdView.h"

@implementation BorderedView
-(id)init{
    self = [super init];
    _borderPosition = BorderPositionTop;
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    _borderPosition = BorderPositionTop;
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    _borderPosition = BorderPositionTop;
    return self;
}
-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor grayColor] setStroke];
    
    if(_borderPosition&BorderPositionTop){
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y);
    }
    if(_borderPosition&BorderPositionLeft){
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y+rect.size.height);
    }
    if(_borderPosition&BorderPositionRight){
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, rect.origin.x+rect.size.width, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    }
    if(_borderPosition&BorderPositionBottom){
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    }
    CGContextStrokePath(context);
}

@end