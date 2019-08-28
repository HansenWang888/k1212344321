#import "WDSegementView.h"
#import "UIButton+AFNetworking.h"
#import <objc/message.h>
@implementation WDSegmentView
{
    NSMutableArray<UILabel* >* _labels;
    UIView*         _sliderview;
    MASConstraint* _sliderleftConstraint;
    NSInteger       _selectedIndex;
    UIColor*        _normalColor;
    UIColor*        _selectedColor;
    
    __weak id              _target;
    SEL             _action;
}
-(id)initWithTitles:(NSArray<NSString*>*)titles SliderLineHeihgt:(CGFloat)sliderLineHeight{
    self = [super init];
    _selectedIndex = -1;
    _labels = [NSMutableArray new];
    NSInteger count = titles.count;

    CGFloat withmultiplier = 1.0/count;
    UIView* lastview = self;
    for(NSInteger i = 0 ; i < count ;++i){
        UILabel* label = [[UILabel alloc]init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.userInteractionEnabled = YES;
        [self addSubview:label];
        
        [label setText:titles[i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        CGFloat multiplier = (float)(i+1)/(float)count;
//        
//        [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:multiplier constant:0].active = YES;
//
//        [label.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:withmultiplier].active = YES;
//        [label.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
//        [label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-sliderLineHeight].active = YES;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.right.equalTo(self).multipliedBy(multiplier);
            make.width.equalTo(self).multipliedBy(withmultiplier);
            make.bottom.offset(-sliderLineHeight);
        }];
        [_labels addObject:label];
        label.tag = i;
        
        UITapGestureRecognizer* tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [label addGestureRecognizer:tapgesture];
        lastview = label;
    }

        
    UIView* transWrapperview = [[UIView alloc]init];
    [self addSubview:transWrapperview];
    transWrapperview.backgroundColor = [UIColor grayColor];
    
    [transWrapperview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.offset(sliderLineHeight);
    }];
    
    _sliderview = [[UIView alloc]init];
    _sliderview.backgroundColor = [UIColor redColor];
    [transWrapperview addSubview:_sliderview];
    
//    _sliderview.translatesAutoresizingMaskIntoConstraints = NO;
//    _sliderleftConstraint =  [_sliderview.leadingAnchor constraintEqualToAnchor:transWrapperview.leadingAnchor ];
//    _sliderleftConstraint.active = YES;
//    [_sliderview.topAnchor constraintEqualToAnchor:transWrapperview.topAnchor].active = YES;
//    [_sliderview.bottomAnchor constraintEqualToAnchor:transWrapperview.bottomAnchor].active = YES;
//    [_sliderview.widthAnchor constraintEqualToAnchor:transWrapperview.widthAnchor  multiplier:withmultiplier].active = YES;
    [_sliderview mas_makeConstraints:^(MASConstraintMaker *make) {
        _sliderleftConstraint = make.left.offset(0);
        make.top.bottom.offset(0);
        make.width.equalTo(transWrapperview).multipliedBy(withmultiplier);
    }];
    
    [self setSelectWithIndex:0 Animated:NO];
    return self;
}
-(void)setFont:(UIFont*)font{
    [_labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setFont:font];
    }];
}
-(NSInteger)getSelectIndex{
    return _selectedIndex;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    CGRect frame = _sliderview.frame;
    _sliderleftConstraint.offset(_selectedIndex*frame.size.width);
}

-(void)setSelectWithIndex:(NSInteger)index Animated:(BOOL)animated{
    assert(index<_labels.count);
    if(_selectedIndex == index) return;
    _selectedIndex = index;

    [_labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx == _selectedIndex) obj.textColor = _selectedColor;
        else obj.textColor = _normalColor;
    }];
    
    CGRect frame = _sliderview.frame;
    if(animated){
        
        [UIView animateWithDuration:0.25    animations:^{
            _sliderleftConstraint.offset(index*frame.size.width);

            [self layoutIfNeeded];
        }];
    }
    else{
        _sliderleftConstraint.offset(index*frame.size.width);
    }
}
-(void)setNormalTextColor:(UIColor*) color{
    if(_normalColor == color) return;
    _normalColor = color;
    [_labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx == _selectedIndex) obj.textColor = _selectedColor;
        else obj.textColor = _normalColor;
    }];
}
-(void)setSelectedTextColor:(UIColor*) color{
    if(_selectedColor == color) return;
    _selectedColor = color;
    _sliderview.backgroundColor = color;
    [_labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx == _selectedIndex) obj.textColor = _selectedColor;
        else obj.textColor = _normalColor;
    }];
    
}
-(void)setTarget:(id)target Action:(SEL)action{
    _target = target;
    _action = action;
}
-(void)onTap:(UITapGestureRecognizer*)gesture{
    NSInteger index = gesture.view.tag;
    if(_selectedIndex == index) return;
    if([_target respondsToSelector:_action]){
      
        
        //[_target performSelector:_action withObject:self];
        void (*objc_msgSendTyped)(id tar, SEL _cmd, NSInteger index)
        = (void*)objc_msgSend;
        objc_msgSendTyped(_target,_action,index);
    }
    [self setSelectWithIndex:index Animated:YES];

}
@end