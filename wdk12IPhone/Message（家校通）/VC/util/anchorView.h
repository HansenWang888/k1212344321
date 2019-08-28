//
//  ListTableView.h
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/22.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

//箭头朝向
#import "AnthorTool.h"

@protocol  AnchorViewDelegate<NSObject>

-(NSInteger)numCells;

-(void)viewForCell:(NSInteger)idx View:(nonnull UIView*)view;

-(void)cellTouched:(NSInteger)idx;
@end

@interface AnchorView : UIView
@property CGFloat start ;
@property CGFloat end;
@property CGFloat anthor;
@property CGFloat lmargin;
@property CGFloat tmargin;
@property CGFloat rmargin;
@property CGFloat bmargin;
@property CGFloat th;
@property AnchorForward anchorForward;
@property CGFloat bg_r;
@property CGFloat bg_g;
@property CGFloat bg_b;
@property CGFloat bg_a;
@property CGFloat li_r;
@property CGFloat li_g;
@property CGFloat li_b;
@property CGFloat li_a;

@property (nonatomic, weak, nullable) id <AnchorViewDelegate> delegate;
-(void)ReloadCell;

@end

