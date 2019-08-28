//
//  HWClassesChoiceView.m
//  wdk12IPhone
//
//  Created by 老船长 on 16/10/25.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "HWClassesChoiceView.h"
#import "HWClassesChoiceItem.h"
#import "HWClassesStudentList.h"

@interface HWClassesChoiceView ()
@property (nonatomic, strong) NSMutableDictionary *itemDict;
@property (nonatomic, copy) NSDictionary *dataDict;
@property (assign, nonatomic) BOOL isLoad;

@end
@implementation HWClassesChoiceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.itemDict = @{}.mutableCopy;
        self.dataDict = @{@"0":@{@"color":COLOR_Creat(57, 199, 200, 1),@"number":@(0)}.mutableCopy,
                          @"1":@{@"color":COLOR_Creat(253, 185, 132, 1),@"number":@(0)}.mutableCopy,
                          @"2":@{@"color":COLOR_Creat(214, 123, 129, 1),@"number":@(0)}.mutableCopy,
                          @"3":@{@"color":COLOR_Creat(152, 180, 88, 1),@"number":@(0)}.mutableCopy};
        for (int i = 0; i < 4; ++i) {
            HWClassesChoiceItem *item = [HWClassesChoiceItem choiceItemView];
            NSMutableDictionary *dict = self.dataDict[[NSString stringWithFormat:@"%d",i]];
            NSArray *symbolArray = @[@"A",@"B",@"C",@"D"];
            item.symbolLabel.text = symbolArray[i];
            item.layer.borderColor = [dict[@"color"] CGColor];
            item.layer.borderWidth = 1.0;
            item.symbolLabel.backgroundColor = dict[@"color"];
            item.numLabel.text = [NSString stringWithFormat:@"%@",dict[@"number"]];
            item.backgroundColor = [UIColor clearColor];
            [self.itemDict setObject:item forKey:symbolArray[i]];
            [self addSubview:item];
        }
        
    }
    return self;
}
- (void)showScanedDataWithStudents:(NSArray *)students {
    
    [self resetData];
    [students enumerateObjectsUsingBlock:^(HWClassesStudentList *list, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"---------%@---------",list.selectedContent);
        HWClassesChoiceItem * item = self.itemDict[list.selectedContent];
        if ([list.selectedContent isEqualToString:item.symbolLabel.text]) {
            NSInteger i = item.numLabel.text.integerValue;
            ++i;
            item.numLabel.text = [NSString stringWithFormat:@"%ld",i];
        }
    }];
    NSLog(@"*******************************");

}
- (void)resetData {
    [self.itemDict.allValues enumerateObjectsUsingBlock:^(HWClassesChoiceItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.numLabel.text = @"0";
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isLoad) {
        CGFloat margin = 20;
        CGFloat width = (CURRENT_DEVICE_SIZE.width - (margin * 5)) / 4 ;
        CGFloat height = 25;
        NSDictionary *dict = @{@"0":@"A",@"1":@"B",@"2":@"C",@"3":@"D"};
        for (int i = 0; i < self.itemDict.allValues.count; ++i) {
            HWClassesChoiceItem *item = self.itemDict[dict[[NSString stringWithFormat:@"%d",i]]];
            CGFloat X = i * margin  + i * width + margin;
            item.frame = CGRectMake(X, 0, width, height);
        }
        self.isLoad = YES;
    }
}
@end
