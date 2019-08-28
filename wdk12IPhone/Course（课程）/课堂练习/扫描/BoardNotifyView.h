//
//  BoardNotifyView.h
//  VideoC
//
//  Created by macapp on 16/8/23.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BoardNotifyView : UIView
    
- (void)loadFilter;

-(void)setIMGWidth:(CGFloat)width Height:(CGFloat)height;

-(void)pushBoards:(NSArray*)boards;
@end
