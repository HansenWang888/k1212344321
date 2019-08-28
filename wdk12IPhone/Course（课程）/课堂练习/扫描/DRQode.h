//
//  DRQode.h
//  VideoC
//
//  Created by macapp on 16/8/19.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKIT/UIKIT.h>
//@import UIKit;
@interface WD_Board_5x5 : NSObject

@property (assign) CGRect border_p;
@property (assign) CGRect border_c;

@property (assign) uint32_t value;
@end

typedef void(^RectBlock)(CGRect rect);
typedef void(^IMGBlock)(UIImage* img,CGRect rect);
typedef void(^BoardResultBlock)(NSArray*);



@interface DRQode : NSObject
+(instancetype)shareInstance;
-(Boolean)busy;
-(void)PushPixelBuffer:(CVImageBufferRef)piexlBufferRef Block:(BoardResultBlock) block;
-(void)PushImage:(UIImage*)img Block:(RectBlock) block;
@end
