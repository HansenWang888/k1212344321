//
//  UIView+ZKAutoLayout.m
//  FFAutoLayout
//
//  Created by 王振坤 on 16/6/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "UIView+ZKAutoLayout.h"

@interface ZK_LayoutAttributes : NSObject

@property (nonatomic, assign) NSLayoutAttribute horizontal;
@property (nonatomic, assign) NSLayoutAttribute referHorizontal;
@property (nonatomic, assign) NSLayoutAttribute vertical;
@property (nonatomic, assign) NSLayoutAttribute referVertical;

- (instancetype)initHorizontal:(NSLayoutAttribute)horizontal referHorizontal:(NSLayoutAttribute)referHorizontal vertical:(NSLayoutAttribute)vertical referVertical:(NSLayoutAttribute)referVertical;
- (instancetype)horizontals:(NSLayoutAttribute)from to:(NSLayoutAttribute)to;
- (instancetype)verticals:(NSLayoutAttribute)from to:(NSLayoutAttribute)to;

@end

@implementation ZK_LayoutAttributes

- (instancetype)init {
    
    if (self = [super init]) {
        self.horizontal    = NSLayoutAttributeLeft;
        self.referVertical = NSLayoutAttributeLeft;
        self.vertical      = NSLayoutAttributeTop;
        self.referVertical = NSLayoutAttributeTop;
    }
    return self;
}

- (instancetype)initHorizontal:(NSLayoutAttribute)horizontal referHorizontal:(NSLayoutAttribute)referHorizontal vertical:(NSLayoutAttribute)vertical referVertical:(NSLayoutAttribute)referVertical {
    self.vertical        = vertical;
    self.horizontal      = horizontal;
    self.referHorizontal = referHorizontal;
    self.referVertical   = referVertical;
    return self;
}

- (instancetype)horizontals:(NSLayoutAttribute)from to:(NSLayoutAttribute)to {
    self.horizontal = from;
    self.referHorizontal = to;
    return self;
}

- (instancetype)verticals:(NSLayoutAttribute)from to:(NSLayoutAttribute)to {
    self.vertical = from;
    self.referVertical = to;
    return self;
}

@end

@implementation UIView (ZKAutoLayout)

- (ZK_LayoutAttributes *)layoutAttributes:(ZK_AlignType)type :(BOOL)isInner isVertical:(BOOL)isVertical {
    ZK_LayoutAttributes *attributes = [ZK_LayoutAttributes new];
    switch (type) {
        case ZK_AlignTypeTopLeft:
            [[attributes horizontals:NSLayoutAttributeLeft to:NSLayoutAttributeLeft] verticals:NSLayoutAttributeTop to:NSLayoutAttributeTop];
            
            if (isInner) {
                return attributes;
            } else if (isVertical) {
                return [attributes verticals:NSLayoutAttributeBottom to:NSLayoutAttributeTop];
            } else {
                return [attributes horizontals:NSLayoutAttributeRight to:NSLayoutAttributeLeft];
            }
            break;
        case ZK_AlignTypeTopRight:
            [[attributes horizontals:NSLayoutAttributeRight to:NSLayoutAttributeRight] verticals:NSLayoutAttributeTop to:NSLayoutAttributeTop];
            
            if (isInner) {
                return attributes;
            } else if (isVertical) {
                return [attributes verticals:NSLayoutAttributeBottom to:NSLayoutAttributeTop];
            } else {
                return [attributes horizontals:NSLayoutAttributeLeft to:NSLayoutAttributeRight];
            }
            break;
        case ZK_AlignTypeTopCenter:
            [[attributes horizontals:NSLayoutAttributeCenterX to:NSLayoutAttributeCenterX] verticals:NSLayoutAttributeTop to:NSLayoutAttributeTop];
            return isInner ? attributes : [attributes verticals:NSLayoutAttributeBottom to:NSLayoutAttributeTop];
            break;
        case ZK_AlignTypeBottomLeft:
            [[attributes horizontals:NSLayoutAttributeLeft to:NSLayoutAttributeLeft] verticals:NSLayoutAttributeBottom to:NSLayoutAttributeBottom];
            
            if (isInner) {
                return attributes;
            } else if (isVertical) {
                return [attributes verticals:NSLayoutAttributeTop to:NSLayoutAttributeBottom];
            } else {
                return [attributes horizontals:NSLayoutAttributeRight to:NSLayoutAttributeLeft];
            }
            break;
        case ZK_AlignTypeBottomRight:
            [[attributes horizontals:NSLayoutAttributeRight to:NSLayoutAttributeRight] verticals:NSLayoutAttributeBottom to:NSLayoutAttributeBottom];
            
            if (isInner) {
                return attributes;
            } else if (isVertical) {
                return [attributes verticals:NSLayoutAttributeTop to:NSLayoutAttributeBottom];
            } else {
                return [attributes horizontals:NSLayoutAttributeLeft to:NSLayoutAttributeRight];
            }
            break;
        case ZK_AlignTypeBottomCenter:
            [[attributes horizontals:NSLayoutAttributeCenterX to:NSLayoutAttributeCenterX] verticals:NSLayoutAttributeBottom to:NSLayoutAttributeBottom];
            return isInner ? attributes : [attributes verticals:NSLayoutAttributeTop to:NSLayoutAttributeBottom];
            break;
        case ZK_AlignTypeCenterLeft:
            [[attributes horizontals:NSLayoutAttributeLeft to:NSLayoutAttributeLeft] verticals:NSLayoutAttributeCenterY to:NSLayoutAttributeCenterY];
            return isInner ? attributes : [attributes horizontals:NSLayoutAttributeRight to:NSLayoutAttributeLeft];
            break;
        case ZK_AlignTypeCenterRight:
            [[attributes horizontals:NSLayoutAttributeRight to:NSLayoutAttributeRight] verticals:NSLayoutAttributeCenterY to:NSLayoutAttributeCenterY];
            return isInner ? attributes : [attributes horizontals:NSLayoutAttributeLeft to:NSLayoutAttributeRight];
            break;
        case ZK_AlignTypeCenterCenter:
            return [[ZK_LayoutAttributes alloc] initHorizontal:NSLayoutAttributeCenterX referHorizontal:NSLayoutAttributeCenterX vertical:NSLayoutAttributeCenterY referVertical:NSLayoutAttributeCenterY];
            break;
        default:
            break;
    }
}

///  位置约束数组
///
///  @param referView  参考视图
///  @param attributes 参照属性
///  @param offset     偏移量
///
///  @return 约束数组
- (NSArray *)zk_positionConstraints:(UIView *)referView attributes:(ZK_LayoutAttributes *)attributes offset:(CGPoint)offset {
    
    NSMutableArray *cons = [NSMutableArray array];

    [cons addObject:[NSLayoutConstraint constraintWithItem:self attribute:attributes.horizontal relatedBy:NSLayoutRelationEqual toItem:referView attribute:attributes.referHorizontal multiplier:1.0 constant:offset.x]];
    [cons addObject:[NSLayoutConstraint constraintWithItem:self attribute:attributes.vertical relatedBy:NSLayoutRelationEqual toItem:referView attribute:attributes.referVertical multiplier:1.0 constant:offset.y]];
    return cons;
}

///  尺寸约束数组
///
///  @param size  参考视图，与参考视图大小一致
///
///  @return 约束数组
- (NSArray *)zk_sizeConstraints:(CGSize)size {
    
    NSMutableArray *cons = [NSMutableArray array];
    
    [cons addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:size.width]];
    [cons addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:size.height]];

    return cons;
}

///  尺寸约束数组
///
///  @param referView  参考视图，与参考视图大小一致
///
///  @return 约束数组
- (NSArray *)zk_sizeConstraintsv:(UIView *)referView {
    
    NSMutableArray *cons = [NSMutableArray array];
    
    [cons addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:referView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [cons addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:referView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    return cons;
}

///  参照参考视图对齐布局
///
///  @param referView  参考视图
///  @param attributes 参照属性
///  @param size       视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset      偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_AlignLayout:(UIView *)referView attributes:(ZK_LayoutAttributes*)attributes size:(CGSize)size offset:(CGPoint)offset {
    
    self.translatesAutoresizingMaskIntoConstraints = false;
    
    NSMutableArray *cons = [NSMutableArray array];
    [cons addObjectsFromArray:[self zk_positionConstraints:referView attributes:attributes offset:offset]];
    
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        [cons addObjectsFromArray:[self zk_sizeConstraints:size]];
    }
    [self.superview addConstraints:cons];
    return cons;
}

///  填充子视图
///
///  @param referView 参考视图
///  @param insets    间距
///
///  @return 约束数组
- (NSArray *)zk_Fill:(UIView *)referView insets:(UIEdgeInsets)insets {
    self.translatesAutoresizingMaskIntoConstraints = false;
    
    NSMutableArray *cons = [NSMutableArray array];
    [cons addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-\(%f)-[subView]-\(%f)-|", insets.left, insets.right] options:NSLayoutFormatAlignAllBaseline metrics:nil views:@{@"subView" : self}]];
    [cons addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-\(%f)-[subView]-\(%f)-|", insets.top, insets.bottom] options:NSLayoutFormatAlignAllBaseline metrics:nil views:@{@"subView" : self}]];
    [self.superview addConstraints:cons];
    return cons;
}

///  参照参考视图内部对齐
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_AlignInner:(ZK_AlignType)type referView:(UIView *)referView size:(CGSize)size offset:(CGPoint)offset {
    return [self zk_AlignLayout:referView attributes:[self layoutAttributes:type :true isVertical:true] size:size offset:offset];
}

///  参照参考视图垂直对齐
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_AlignVertical:(ZK_AlignType)type referView:(UIView *)referView size:(CGSize)size offset:(CGPoint)offset {
    return [self zk_AlignLayout:referView attributes:[self layoutAttributes:type :false isVertical:true] size:size offset:offset];
}

///  参照参考视图水平对齐
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_AlignHorizontal:(ZK_AlignType)type referView:(UIView *)referView size:(CGSize)size offset:(CGPoint)offset {
    return [self zk_AlignLayout:referView attributes:[self layoutAttributes:type :false isVertical:false] size:size offset:offset];
}

///  在当前视图内部水平平铺控件
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_HorizontalTile:(NSArray<UIView *>*)views insets:(UIEdgeInsets)insets {
    NSAssert(views.count != 0 && views != nil, @"views should not be empty");
    NSMutableArray *cons = [NSMutableArray array];
    UIView *firstView = views[0];
    [firstView zk_AlignInner:ZK_AlignTypeTopLeft referView:self size:CGSizeZero offset:CGPointMake(insets.left, insets.top)];
    [cons addObject:[NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-insets.bottom]];
    // 添加后续视图的约束
    UIView *preView = firstView;
    for (int i = 1; i<views.count; i++) {
        UIView *subView = views[i];
        [cons addObjectsFromArray:[subView zk_sizeConstraintsv:firstView]];
        [subView zk_AlignHorizontal:ZK_AlignTypeTopRight referView:preView size:CGSizeZero offset:CGPointMake(insets.right, 0)];
        preView = subView;
    }
    
    UIView *lastView = views.lastObject;
    [cons addObject:[NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-insets.right]];
    
    [self addConstraints:cons];
    
    return cons;
}

///  在当前视图内部垂直平铺控件
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_VerticalTile:(NSArray<UIView *>*)views insets:(UIEdgeInsets)insets {
    NSAssert(views.count != 0 && views != nil, @"views should not be empty");
    NSMutableArray *cons = [NSMutableArray array];
    UIView *firstView = views[0];
    [firstView zk_AlignInner:ZK_AlignTypeTopLeft referView:self size:CGSizeZero offset:CGPointMake(insets.left, insets.top)];
    [cons addObject:[NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-insets.right]];
    // 添加后续视图的约束
    UIView *preView = firstView;
    for (int i = 1; i<views.count; i++) {
        UIView *subView = views[i];
        [cons addObjectsFromArray:[subView zk_sizeConstraintsv:firstView]];
        [subView zk_AlignVertical:ZK_AlignTypeBottomLeft referView:preView size:CGSizeZero offset:CGPointMake(0, insets.bottom)];
        preView = subView;
    }
    
    UIView *lastView = views.lastObject;
    [cons addObject:[NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-insets.bottom]];
    
    [self addConstraints:cons];
    
    return cons;
}

///  从约束数组中查找指定 attribute 的约束
///
///  @param constraintsList 约束数组
///  @param attribute       约束属性
///
///  @return 对应的约束
- (NSLayoutConstraint *)zk_Constraint:(NSArray <NSLayoutConstraint *>*)constraintsList attribute:(NSLayoutAttribute)attribute {
    for (NSLayoutConstraint *constraint in constraintsList) {
        if (constraint.firstItem == self && [constraint firstAttribute] == attribute) {
            return constraint;
        }
    }
    return nil;
}

@end
