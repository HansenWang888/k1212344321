//
//  BoardNotifyView.m
//  VideoC
//
//  Created by macapp on 16/8/23.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "BoardNotifyView.h"
#import "DRQode.h"
@implementation BoardNotifyView
{
    NSArray* _boards;
    CGFloat      _width;
    CGFloat      _height;
    NSDictionary* _fontAttr;
    NSMutableIndexSet* _sets;
}

- (void)loadFilter {
    NSString *txtPath=[[NSBundle mainBundle]pathForResource:@"CExerciseEncode" ofType:@"txt"];
    NSStringEncoding *useEncodeing = nil;
    NSString *body = [NSString stringWithContentsOfFile:txtPath usedEncoding:useEncodeing error:nil];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    _sets = [NSMutableIndexSet new];
    [[dic objectForKey:@"fbtbm"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_sets addIndex: [[obj objectForKey:@"bmz"] integerValue]];
    }];
}
-(void)setIMGWidth:(CGFloat)width Height:(CGFloat)height{
    _width = width;
    _height = height;
}
-(void)pushBoards:(NSArray*)boards{
    _boards = boards;
    [self setNeedsDisplay];
}
#define FONT_SIZE      25
#define FONT_ATTRIBUTE  @{\
NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE], \
NSForegroundColorAttributeName:[UIColor redColor]}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat vW = self.bounds.size.width;
    CGFloat vH = self.bounds.size.height;
    [_boards enumerateObjectsUsingBlock:^(WD_Board_5x5*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![_sets containsIndex: obj.value]) return ;
        CGRect rect = obj.border_p;
        rect.origin.x = rect.origin.x*(vW/_width);
        rect.origin.y = rect.origin.y*(vH/_height);
        rect.size.width = rect.size.width*(vW/_width);
        rect.size.height = rect.size.height*(vH/_height);
        CGContextAddRect(context, rect);
//        NSString* valueStr = [NSString stringWithFormat:@"%u",obj.value];
//        CGPoint center = CGPointMake(  rect.origin.x+rect.size.width/2.0,
//                                      rect.origin.y+rect.size.height/2.0);
        
        if(_fontAttr == nil) _fontAttr = FONT_ATTRIBUTE;
        
//        [valueStr drawAtPoint:center withAttributes:_fontAttr];
    }];
    CGContextSetLineWidth(context, 3.0);
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    
    CGContextStrokePath(context);
}
@end
