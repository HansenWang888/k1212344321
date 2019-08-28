//
//  AnthorTool.h
//  wdk12IPhone
//
//  Created by macapp on 15/11/11.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#ifndef AnthorTool_h
#define AnthorTool_h
#import <Foundation/Foundation.h>
#import <UIKIT/UIKIT.h>
typedef enum {
    AnchorForwardNone = 0,
    AnchorForwardLeft ,
    AnchorForwardTop,
    AnchorForwardRight,
    AnchorForwardBottom,
}AnchorForward;
typedef struct{
    float x;
    float y;
    float w;
    float h;
    float r;
    
    float ml;
    float mr;
    float mt;
    float mb;
    AnchorForward forward;
    float anchor;
    float as;
    float ae;
} DRC;



CGPoint Getp1(DRC* rc);
CGPoint Getp2(DRC* rc);
CGPoint Getp12(DRC* rc);
CGPoint Getp3(DRC* rc);
CGPoint Getp4(DRC* rc);
CGPoint Getp34(DRC* rc);
CGPoint Getp5(DRC* rc);
CGPoint Getp6(DRC* rc);
CGPoint Getp56(DRC* rc);
CGPoint Getp7(DRC* rc);
CGPoint Getp8(DRC* rc);
CGPoint Getp78(DRC* rc);
void GetPoints(DRC* rc,CGFloat start,CGFloat end,CGFloat anchor, AnchorForward forward,CGPoint* ps,CGPoint* pa,CGPoint* pe);
void drawPath(CGContextRef context, DRC rc,CGRect rect);
#endif /* AnthorTool_h */
