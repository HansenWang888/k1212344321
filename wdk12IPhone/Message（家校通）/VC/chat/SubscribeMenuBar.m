//
//  SubscribeMenuBar.m
//  wdk12pad
//
//  Created by macapp on 16/2/19.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "SubscribeMenuBar.h"
#import "subscribeModule.h"
#import "anchorView.h"
#define BACK_WITH 45.0
@interface SubscribeMenuBar()<AnchorViewDelegate>
@end
@implementation SubscribeMenuBar
{
    NSString* _sbid;
    NSArray* _menus;
    NSArray* _subMenus;
    UIButton* _backBtn;
    UIButton* _selectBtn;
    NSMutableArray<UIButton*>* _menuBtns;
    
    AnchorView* _inscreenSubMenuView;
    UIView*     _otherhideview;
}
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    UIView* ret = [super hitTest:point withEvent:event];
    if(ret) return ret;
    if(_inscreenSubMenuView){
        
        CGPoint tempoint = [_inscreenSubMenuView convertPoint:point fromView:self];
        
        if(CGRectContainsPoint(_inscreenSubMenuView.bounds, tempoint)){
            return [_inscreenSubMenuView hitTest:tempoint withEvent:event];
        }
        else{
            return _otherhideview;
        }
    }
    return nil;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 0.5,0.5,0.5,1);
    CGFloat dimstart = rect.origin.x+BACK_WITH;
    
    
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, dimstart, rect.origin.y);
    CGContextAddLineToPoint(context, dimstart, rect.origin.y+rect.size.height);
    
    if(_menus&& _menus.count>1){
        CGFloat dimwidth = (rect.size.width-BACK_WITH)/_menus.count;
        for(NSInteger i = 1 ; i < _menus.count ; ++i){
            CGFloat subdimstart = dimstart+dimwidth*i;
            CGContextMoveToPoint(context, subdimstart , rect.origin.y);
            CGContextAddLineToPoint(context, subdimstart, rect.origin.y+rect.size.height);
            
        }
    }
    
    CGContextStrokePath(context);
}

-(void)setSbid:(NSString*)sbid{
    assert(_sbid == nil);
    self.userInteractionEnabled = YES;
    _sbid = sbid;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuUpdate:) name:DDNotificationSubscribeInfoUpdate object:nil];
    [self menuUpdateImpl:sbid];
    [[SubscribeModule shareInstance]getSBMenuInfoWithNotification:sbid ForUpdate:YES];
    
    
    _backBtn = [[UIButton alloc]init];
    _backBtn.titleLabel.font =  [UIFont fontWithName:@"iconfont" size:33];
    [_backBtn setTitle:@"\U0000E63B" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.offset(BACK_WITH);
    }];
    [_backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
}
-(void)menuUpdate:(NSNotification*)notify{
    NSString* sbuuid = notify.object[0];
    if(![sbuuid isEqualToString:_sbid]) return;
    SubscribeUpdateType type = [notify.object[1] integerValue];
    if(type != SubscribeUpdateTypeMenu) return;
    [self menuUpdateImpl:_sbid];
}
-(void)menuUpdateImpl:(NSString*)sbid{
    //异步解析
    NSString* menu = [[SubscribeModule shareInstance]getSBMenuBySBID:sbid];
    
    if(menu == nil) return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* menus = [NSJSONSerialization JSONObjectWithData:[menu dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        
        if(menus != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self generateMenu:menus];
            });
            
        }
    });
}
-(void)clearMenu{
    _selectBtn = nil;
    if(!_menuBtns) return;
    [_menuBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    _menuBtns = nil;
    _menus = nil;
}
-(void)clearSubMenu{
    _selectBtn = nil;
    if(_inscreenSubMenuView) {
        [_inscreenSubMenuView removeFromSuperview];
        [_otherhideview removeFromSuperview];
    }
    _otherhideview = nil;
    _inscreenSubMenuView = nil;
    _subMenus = nil;
}
-(void)generateMenu:(NSArray*)menus{
    //清除上次的
    [self clearMenu];
    [self clearSubMenu];
    _menuBtns = [NSMutableArray new];
    [self setNeedsDisplay];
    _menus = menus;
    __block UIButton* frontbtn = _backBtn;
    [_menus enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton* menubtn = [[UIButton alloc]init];
        NSLog(@"-------%@",[obj objectForKey:@"menuname"]);
        [menubtn setTitle:[obj objectForKey:@"menuname"] forState:UIControlStateNormal];
        [menubtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:menubtn];
        [menubtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(frontbtn.mas_right);
            make.top.bottom.offset(0);
            make.width.equalTo(self.mas_width).offset(-(BACK_WITH)/_menus.count).multipliedBy(1.0/_menus.count);
        }];
        [menubtn setTag:idx];
        frontbtn = menubtn;
        [menubtn addTarget:self action:@selector(onSubClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_menuBtns addObject:menubtn];
    }];
}
-(void)onBack{
    if(_delegate) [_delegate onBack];
}
-(void)onSubClicked:(UIButton*)sender{
    if(_selectBtn==sender){
        [self clearSubMenu];
        return;
    }
    [self clearSubMenu];
    
    NSArray* submenu = [_menus[sender.tag] objectForKey:@"childMenulist"];
    if(![submenu isKindOfClass:[NSArray class]]){
        return;
    }
    if(submenu.count == 0){
        [self onTouch:_menus[sender.tag]];
        return;
    }
    _selectBtn = sender;
    
    
    CGRect anchorframe = _selectBtn.frame;
    CGFloat height = submenu.count*BACK_WITH+20;
    anchorframe.origin.y -= height;
    anchorframe.size.height = height;
    _inscreenSubMenuView = [[AnchorView alloc]initWithFrame:anchorframe];
    _inscreenSubMenuView.userInteractionEnabled = YES;
    _inscreenSubMenuView.backgroundColor = [UIColor clearColor];
    _inscreenSubMenuView.anchorForward = AnchorForwardBottom;
    _inscreenSubMenuView.anthor = 0.5;
    _inscreenSubMenuView.start  = 0.45;
    _inscreenSubMenuView.end = 0.55;
    _inscreenSubMenuView.bmargin = 10;
    
    CGFloat r,g,b,a;
    [[UIColor groupTableViewBackgroundColor] getRed:&r green:&g blue:&b alpha:&a];
    _inscreenSubMenuView.bg_r = r;
    _inscreenSubMenuView.bg_g = g;
    _inscreenSubMenuView.bg_b = b;
    _inscreenSubMenuView.bg_a = a;
    [[UIColor lightGrayColor] getRed:&r green:&g blue:&b alpha:&a];
    _inscreenSubMenuView.li_r = r;
    _inscreenSubMenuView.li_g = g;
    _inscreenSubMenuView.li_b = b;
    _inscreenSubMenuView.li_a = a;
    [self addSubview:_inscreenSubMenuView];
    _subMenus = submenu;
    _inscreenSubMenuView.delegate = self;
    _inscreenSubMenuView.userInteractionEnabled = YES;
    [_inscreenSubMenuView ReloadCell];
    
    _otherhideview = [[UIView alloc]init];
    [self addSubview:_otherhideview];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onOtherHideTap)];
    [_otherhideview addGestureRecognizer:gesture];
}

-(void)onOtherHideTap{
    [self clearSubMenu];
}
#pragma mark anchordelegate
-(NSInteger)numCells{
    return _subMenus.count;
}

-(void)viewForCell:(NSInteger)idx View:(nonnull UIView*)view{
    NSInteger reverseidx = _subMenus.count-idx-1;
    view.userInteractionEnabled = YES;
    UILabel* label = [[UILabel alloc]init];
    label.text = [_subMenus[reverseidx] objectForKey:@"menuname"];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:20.0];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.height.equalTo(view);
    }];
    label.textAlignment = NSTextAlignmentCenter;
}
-(void)onTouch:(NSDictionary*)dic{
    
    NSInteger menutype = [[dic objectForKey:@"menutype"] integerValue];
    if(menutype == 1){
        NSInteger contenttype = [[dic objectForKey:@"contenttype"] integerValue] ;
        //文字
        if(contenttype == 1){
            NSString*  menucontent = [dic objectForKey:@"menucontent"] ;
            [_delegate onMate:@{@"contenttype":@(1),@"text":menucontent}];
        }
        if(contenttype == 3){
            NSDictionary* mate = [dic objectForKey:@"materialView"];
            if(mate  && [mate objectForKey:@"id"]){
                [_delegate onMate:@{@"contenttype":@(3),@"mate":mate}];
            }
        }
        if(contenttype == 2){
            NSDictionary* mate = [dic objectForKey:@"materialView"];
            if(mate && [mate objectForKey:@"id"]){
                NSString* httpurl = [mate objectForKey:@"matbody"];
                [_delegate onMate:@{@"contenttype":@(2),@"httpurl":httpurl}];
            }
        }
        if(contenttype == 4||contenttype == 5||contenttype == 6){
            NSDictionary* mate = [dic objectForKey:@"materialView"];
            if(mate && [mate objectForKey:@"id"]){
                
                NSString* oringinUrl = [mate objectForKey:@"matbody"];
                NSString* transUrl = [mate objectForKey:@"transaddr"];
                NSString* title = [mate objectForKey:@"title"];
                NSString* size  = [mate objectForKey:@"size"];
                [_delegate onMate:@{@"contenttype":@(6),@"originurl":oringinUrl,@"transurl":transUrl,@"filename":title,@"filesize":size}];
            }
        }
    }
    //超链接
    else if(menutype == 2){
        NSString*  hyperLink = [dic objectForKey:@"menucontent"] ;
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReqeustHyperLink object:@[_sbid,hyperLink,IMLocalizedString(@"链接", nil)]];
    }
    else{
        
    }
}
-(void)cellTouched:(NSInteger)idx{
    if(_subMenus.count < idx) return;
    NSInteger reverseidx = _subMenus.count-idx-1;
    [self onTouch:_subMenus[reverseidx]];
    
    [self clearSubMenu];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
