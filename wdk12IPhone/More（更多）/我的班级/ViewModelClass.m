//
//  ViewModelClass.m
//  wdk12IPhone
//
//  Created by 王振坤 on 16/7/19.
//  Copyright © 2016年 伟东云教育. All rights reserved.
//

#import "ViewModelClass.h"

@implementation ViewModelClass

#pragma 接收穿过来的block
-(void) setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock
               WithFailureBlock: (FailureBlock) failureBlock
{
    _returnBlock = returnBlock;
    _errorBlock = errorBlock;
    _failureBlock = failureBlock;
}

@end
