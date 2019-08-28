//
//  DRQode.m
//  VideoC
//
//  Created by macapp on 16/8/19.
//  Copyright © 2016年 macapp. All rights reserved.
//

#import "DRQode.h"


#include "5X5BoardAPI.h"
#include <coreimage/coreimage.h>
#include <set>
//@import UIKit;
//@import CoreImage;

using std::set;

@implementation WD_Board_5x5
@end

void showValue(uint32_t value){
    for(int x = 0 ; x < 5 ; ++x){
        for(int y = 0 ; y < 5 ; ++y){
            printf("%d ",value>>(y+5*x)&1);
        }
        printf("\n");
    }
}
@implementation DRQode
{
    Boolean _busy;
    dispatch_queue_t _detectQueue;
    NSLock*           _lock;
   
    FILE    *_bgraFile;
    int      _frameCnt;
    set<int> mValues;
}
+(instancetype)shareInstance{
    static DRQode* g_DRQode;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_DRQode = [[DRQode alloc] init];
    });
    return g_DRQode;
}
-(Boolean)busy{
    NSLog(@"_busy:%d",_busy);
    return _busy;
}
-(id)init{
    self = [super init];
    _lock = [[NSLock alloc]init];
    _detectQueue = dispatch_queue_create("com.drqode.wd", NULL);
    
    
    _busy = NO;
    

    return self;
}
-(void)PushPixelBuffer:(CVImageBufferRef)piexlBufferRef Block:(BoardResultBlock) block{
    if(_busy) return;
    _busy = YES;
    CVPixelBufferRetain(piexlBufferRef);
    dispatch_async(_detectQueue, ^{
    @autoreleasepool {
      
        CVPixelBufferLockBaseAddress(piexlBufferRef, 0);
    
        void* data = CVPixelBufferGetBaseAddress(piexlBufferRef);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(piexlBufferRef);
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(piexlBufferRef);
        size_t height = CVPixelBufferGetHeight(piexlBufferRef);
        size_t data_size = width*height*4;
        //NSLog(@"%u,%u,%u,%d",width,height,bytesPerRow,data_size);
        Board_Bridge_Vec out_bridge_vec;
        find_board_bridge_bgra_data(data, width, height,bytesPerRow, out_bridge_vec, 10.f);
        
        CVPixelBufferUnlockBaseAddress(piexlBufferRef, 0);
        CVPixelBufferRelease(piexlBufferRef);
        
        NSMutableArray* boards = [NSMutableArray new];
        for(int i = 0 ; i < out_bridge_vec.size() ; ++i){
            WD_Board_5x5* wdboard = [WD_Board_5x5 new];
            wdboard.border_p = CGRectMake(out_bridge_vec[i].x, out_bridge_vec[i].y, out_bridge_vec[i].w, out_bridge_vec[i].h);
            wdboard.value = out_bridge_vec[i].value;
            [boards addObject:wdboard];
         //   showValue(wdboard.value);
        }
        block(boards);
           
        
        _frameCnt ++;
        _busy = NO;
        
    }
    });

}

@end
