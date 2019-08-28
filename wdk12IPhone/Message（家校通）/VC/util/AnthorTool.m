//
//  AnthorTool.m
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnthorTool.h"



CGPoint Getp1(DRC* rc){
    CGPoint point;
    point.x = rc->x;
    point.y = rc->y+rc->r;
    return point;
};
CGPoint Getp2(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->r;
    point.y = rc->y;
    return point;
};
CGPoint Getp12(DRC* rc){
    CGPoint point;
    point.x = rc->x;
    point.y = rc->y;
    return point;
};
CGPoint Getp3(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->w-rc->r;
    point.y = rc->y;
    return point;
};
CGPoint Getp4(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->w;
    point.y = rc->y+rc->r;
    return point;
};
CGPoint Getp34(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->w;
    point.y = rc->y;
    return point;
};
CGPoint Getp5(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->w;
    point.y = rc->y+rc->h-rc->r;
    return point;
};
CGPoint Getp6(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->w-rc->r;
    point.y = rc->y+rc->h;
    return point;
};
CGPoint Getp56(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->w;
    point.y = rc->y+rc->h;
    return point;
};
CGPoint Getp7(DRC* rc){
    CGPoint point;
    point.x = rc->x+rc->r;
    point.y = rc->y+rc->h;
    return point;
};
CGPoint Getp8(DRC* rc){
    CGPoint point;
    point.x = rc->x;
    point.y = rc->y+rc->h-rc->r;
    return point;
};
CGPoint Getp78(DRC* rc){
    CGPoint point;
    point.x = rc->x;
    point.y = rc->y+rc->h;
    return point;
};
void GetPoints(DRC* rc,CGFloat start,CGFloat end,CGFloat anchor, AnchorForward forward,CGPoint* ps,CGPoint* pa,CGPoint* pe){
    switch (forward) {
        case AnchorForwardTop:
            ps->x = rc->x+rc->w*start;
            ps->y = rc->y;
            pe->x = rc->x+rc->w*end;
            pe->y = rc->y;
            pa->x = rc->x+rc->w*anchor;
            pa->y = rc->y - rc->mt;
            break;
        case AnchorForwardBottom:
            start = 1.0-start;
            end = 1.0-end;
            anchor = 1.0-anchor;
            ps->x = rc->x+rc->w*start;
            ps->y = rc->y+rc->h;
            pe->x = rc->x+rc->w*end;
            pe->y = rc->y+rc->h;
            pa->x = rc->x+rc->w*anchor;
            pa->y = rc->y + rc->mb +rc->h;
            break;
        case AnchorForwardRight:
            ps->x = rc->x+rc->w;
            ps->y = rc->y+rc->h*start;
            pe->x = rc->x+rc->w;
            pe->y = rc->y+rc->h*end;
            pa->x = rc->x+rc->w+rc->mr;
            pa->y = rc->y+rc->h*anchor;;
            break;
        case AnchorForwardLeft:
            ps->x = rc->x;
            ps->y = rc->y+rc->h*start;
            pe->x = rc->x;
            pe->y = rc->y+rc->h*end;
            pa->x = rc->x-rc->ml;
            pa->y = rc->y+rc->h*anchor;
            break;
        default:
            break;
    }
}
void reRect(CGRect rect ,DRC* rc);
void drawPath(CGContextRef context,DRC rc,CGRect rect){
    
    reRect(rect, &rc);
    
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
    
    if(rc.forward == AnchorForwardTop){
        CGPoint ps,pa,pe;
        GetPoints(&rc, rc.as, rc.ae, rc.anchor, rc.forward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
    }
    else{
        CGContextAddLineToPoint(context, p3.x, p3.y);
    }
    //   goto enddraw;
    
    CGContextAddArcToPoint(context, p34.x, p34.y, p4.x, p4.y, rc.r);
    if(rc.forward == AnchorForwardRight){
        CGPoint ps,pa,pe;
        GetPoints(&rc, rc.as, rc.ae, rc.anchor, rc.forward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
    }
    else{
        CGContextAddLineToPoint(context, p5.x, p5.y);
    }
    
    
    CGContextAddArcToPoint(context, p56.x, p56.y, p6.x, p6.y, rc.r);
    if(rc.forward == AnchorForwardBottom){
        CGPoint ps,pa,pe;
        GetPoints(&rc, rc.as, rc.ae, rc.anchor, rc.forward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
    }
    else{
        CGContextAddLineToPoint(context, p7.x, p7.y);
    }
    
    
    CGContextAddArcToPoint(context, p78.x, p78.y, p8.x, p8.y, rc.r);
    if(rc.forward == AnchorForwardLeft){
        CGPoint ps,pa,pe;
        GetPoints(&rc, rc.as, rc.ae, rc.anchor, rc.forward, &ps, &pa, &pe);
        CGContextAddLineToPoint(context, ps.x, ps.y);
        CGContextAddLineToPoint(context, pa.x, pa.y);
        CGContextAddLineToPoint(context, pe.x, pe.y);
    }
    else{
        CGContextAddLineToPoint(context, p1.x, p1.y);
    }
    
    CGContextClosePath(context);
}

void reRect(CGRect rect ,DRC* rc){
    rc->x = rc->ml;
    rc->y = rc->mt;
    rc->w = rect.size.width - rc->ml - rc->mr;
    rc->h = rect.size.height - rc->mt - rc->mb;
}
