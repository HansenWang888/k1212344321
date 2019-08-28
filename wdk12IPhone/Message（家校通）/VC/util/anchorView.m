
#import "anchorView.h"


@implementation AnchorView
{
    DRC rc;
    NSMutableArray* subTitles;
}
-(id)init{
    self = [super init];
    
    [self initValues];
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];

    [self initValues];
    return self;
}
#pragma mark render
-(void)initValues{
    subTitles = [NSMutableArray new];
    

    _start = 0.0;
    _end = 0.0;
    _anthor = 0.0;
    _lmargin = 0;
    _tmargin = 0.0;
    _rmargin = 0.0;
    _bmargin = 0.0;
    _th = 0.0;
    _anchorForward = AnchorForwardNone;
    _bg_r = _bg_g= _bg_b =0.3;
    _bg_a = 1.0;
    _li_r = _li_g = _li_b = _li_a = 1.0;
}
-(void)compileRCWithRect:(CGRect)rect{
    rc.x = _lmargin;
    rc.y = _tmargin;
    rc.w = rect.size.width - _lmargin - _rmargin;
    rc.h = rect.size.height - _tmargin - _bmargin;
    rc.r = 5.0;
    rc.ml = _lmargin;
    rc.mr = _rmargin;
    rc.mb = _bmargin;
    rc.mt = _tmargin;
}
- (void)drawRect:(CGRect)rect{
    [self compileRCWithRect:rect];
    

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, _bg_r,_bg_g,_bg_b,_bg_a);

    
    CGContextSetLineWidth(context, 2.0);

    CGPoint p1 = Getp1(&rc);
    CGPoint p2 = Getp2(&rc);
    CGPoint p12 = Getp12(&rc);
    CGPoint p3 = Getp3(&rc);
    CGPoint p4 = Getp4(&rc);
    CGPoint p34 = Getp34(&rc);
    CGPoint p5 = Getp5(&rc);
    CGPoint p6 = Getp6(&rc);
    CGPoint p56 = Getp56(&rc);
    CGPoint p7 = Getp7(&rc);
    CGPoint p8 = Getp8(&rc);
    CGPoint p78 = Getp78(&rc);
    
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
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 0.8);
    CGContextSetLineWidth(context, 1);
    CGContextDrawPath(context, kCGPathFillStroke);
    

    if(_delegate){
        CGContextSetRGBStrokeColor(context, _li_r, _li_g, _li_b, _li_a);
        CGContextSetLineWidth(context, 1.0);
        NSInteger cellnum = [_delegate numCells];
        
        for(NSInteger i = 0 ; i < cellnum -1 ; ++i){
            CGFloat baseheight = rc.h/cellnum;
            for(NSInteger i = 0 ; i < cellnum-1;++i){
                CGContextMoveToPoint(context, rc.x+10, rc.y+ (i+1)*baseheight);
                CGContextAddLineToPoint(context, rc.x+rc.w-10, rc.y+ (i+1)*baseheight);
            }
        }
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
}

//function array
#pragma mark function
-(void)ReloadCell{

    if(_delegate){
        [self compileRCWithRect:self.frame];
        for(UIView *view in [self subviews])
        {
            [view removeFromSuperview];
        }
        NSInteger cellnum = [_delegate numCells];
        if(cellnum == 0) return;
        CGFloat baseheight = rc.h/cellnum;
        for(NSInteger i = 0 ; i < cellnum;++i){
            
            UIView* view = [[UIView alloc]initWithFrame:CGRectMake(rc.x,rc.y+ i*baseheight, rc.w, baseheight)];
            [self addSubview:view];
            view.tag = i;
            [_delegate viewForCell:i View:view];
            UITapGestureRecognizer* toucheinside = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(SingleTap:)];
            
            [view addGestureRecognizer:toucheinside];
        }
        
    }
}
-(void)SingleTap:(UITapGestureRecognizer*)recognizer{
    
    [_delegate cellTouched:recognizer.view.tag];
}
@end