//
//  UIView+ZKAutoLayout.h
//  FFAutoLayout
//
//  Created by 王振坤 on 16/6/13.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZKAutoLayout)

typedef NS_ENUM(NSInteger, ZK_AlignType) {
    ZK_AlignTypeTopLeft,
    ZK_AlignTypeTopRight,
    ZK_AlignTypeTopCenter,
    ZK_AlignTypeBottomLeft,
    ZK_AlignTypeBottomRight,
    ZK_AlignTypeBottomCenter,
    ZK_AlignTypeCenterLeft,
    ZK_AlignTypeCenterRight,
    ZK_AlignTypeCenterCenter,
};

///  填充子视图
///
///  @param referView 参考视图
///  @param insets    间距
///
///  @return 约束数组
- (NSArray *)zk_Fill:(UIView *)referView insets:(UIEdgeInsets)insets;

///  参照参考视图内部对齐
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_AlignInner:(ZK_AlignType)type referView:(UIView *)referView size:(CGSize)size offset:(CGPoint)offset;

///  参照参考视图垂直对齐
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_AlignVertical:(ZK_AlignType)type referView:(UIView *)referView size:(CGSize)size offset:(CGPoint)offset;

///  参照参考视图水平对齐
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_AlignHorizontal:(ZK_AlignType)type referView:(UIView *)referView size:(CGSize)size offset:(CGPoint)offset;

///  在当前视图内部水平平铺控件
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_HorizontalTile:(NSArray<UIView *>*)views insets:(UIEdgeInsets)insets;

///  从约束数组中查找指定 attribute 的约束
///
///  @param constraintsList 约束数组
///  @param attribute       约束属性
///
///  @return 对应的约束
- (NSLayoutConstraint *)zk_Constraint:(NSArray <NSLayoutConstraint *>*)constraintsList attribute:(NSLayoutAttribute)attribute;

///  在当前视图内部垂直平铺控件
///
///  @param type      对齐方式
///  @param referView 参考视图
///  @param size      视图大小，如果是 CGSizeZero 则不设置大小
///  @param offset    偏移量，默认是 CGPoint(x: 0, y: 0)
///
///  @return 约束数组
- (NSArray *)zk_VerticalTile:(NSArray<UIView *>*)views insets:(UIEdgeInsets)insets;

@end
