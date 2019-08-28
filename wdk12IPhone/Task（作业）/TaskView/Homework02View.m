//
//  Homework02View.m
//  手机端试题原生化
//
//  Created by 老船长 on 16/8/13.
//  Copyright © 2016年 伟东. All rights reserved.
//

#import "Homework02View.h"
#import "Homework02TextCell.h"

@interface Homework02View ()
@property (assign, nonatomic) NSInteger inputCount;

@end
@implementation Homework02View

- (void)setupSubCell {
    NSMutableArray *arrayM = @[].mutableCopy;
    self.info.sttg = [self delHTMLInputWithString:self.info.sttg];
    [arrayM addObject:[self creatTopicCell]];
    for (int i = 0; i<self.inputCount; ++i) {
        Homework02TextCell *cell = [Homework02TextCell new];
        cell.numLabel.text = [NSString stringWithFormat:@"%d", i+1];
        cell.textField.tag = i + 1;
        self.cellHeightCache[[NSString stringWithFormat:@"%d",i + 1]] = @(50);
        [arrayM addObject:cell];
    }
    self.subCells = arrayM.copy;

}
- (void)insertAnswerToTask {
    int i = 0;
    for (Homework02TextCell *cell  in self.subCells) {
        if (cell.class == [Homework02TextCell class]) {
            if ([self.info.mystda length] > 0) {
                NSArray *da = [self.info.mystda componentsSeparatedByString:@"<br />"];
                if (i < da.count) {
                    NSString *str = [NSString stringWithFormat:@"%@%@</body><style>body,html{font-size: 14px;width:100%%;}img{max-width:%f !important;}</style></html>", @"<html><body>", da[i] ? da[i] : @"", [UIScreen wd_screenWidth] - 20];
                    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
                    cell.textField.attributedText = attr;
                }
                i++;
            }
        }
    }
}
- (NSString *)delHTMLInputWithString:(NSString *)str {
    NSMutableString *newStr = [NSMutableString stringWithString:str];
    NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:@"<input.*?>" options:0 error:nil];
    NSRange range = NSMakeRange(0, newStr.length);
    self.inputCount = [expr replaceMatchesInString:newStr options:0 range:range withTemplate:@"___________ "];
    return newStr;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
