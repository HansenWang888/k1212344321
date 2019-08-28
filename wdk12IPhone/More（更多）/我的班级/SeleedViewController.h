//
//  SeleedViewController.h
//  wdk12IPhone
//
//  Created by cindy on 15/11/13.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol seleedViewDelegate <NSObject>

@required  //注意！！！
-(void)selectedWithDic:(NSDictionary*)selectedDic andType:(int)type;

@end

@interface SeleedViewController : UIViewController

@property (nonatomic, weak) id<seleedViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *title_label;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;


//这个参数根据传入不同的type 来更改cell解析Dic时用的key
//1选择年级  2选择班级 3我要提问－选择课程
@property (nonatomic,assign)int type;



-(void)beginMySelfWithData:(NSArray*)data;


@end
