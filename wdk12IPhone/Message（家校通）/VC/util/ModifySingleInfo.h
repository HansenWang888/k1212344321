//
//  MessageViewController.h
//  wdk12IPhone
//
//  Created by 布依男孩 on 15/9/16.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ModifySingleValueType){
    ModifySingleValueTyperRmkname = 0,
    ModifySingleValueTypeVerify,
    ModifySingleValueTypeGroupName,
    ModifySingleValueTypeGroupMyNick
};

@interface ModifySingleInfo : UIViewController

-(id)initWithModifyType:(ModifySingleValueType) modifySingleValueType ObjectID:(NSString*)objid DefaultValue:(NSString*)defaultValue;

@end
