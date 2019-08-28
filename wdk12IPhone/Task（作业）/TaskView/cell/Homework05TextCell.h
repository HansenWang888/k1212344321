//
//  WebViewEditTableViewCell.h
//  wdk12pad
//
//  Created by 王振坤 on 16/7/29.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <UIKit/UIKit.h>

///  webView编辑
//@protocol Homework05TextCellDelegate <NSObject>
//
//- (void)EditTableViewCellUploadPhotoAttachment:(NSData *)imageData finished:(void(^)(NSString *imagURL))finished;
//
//@end

@interface Homework05TextCell : UITableViewCell

@property (nonatomic, copy) NSString *answer;

///  内容label
@property (nonatomic, strong) UILabel *contentLabel;

//@property (weak, nonatomic) id<Homework05TextCellDelegate> delegate;

//@property (nonatomic, weak) UIViewController *superViewController;


///  获取提交内容方法
//- (NSString *)getSubmitContentBlock:(void(^)(NSArray *data))block;

@end
