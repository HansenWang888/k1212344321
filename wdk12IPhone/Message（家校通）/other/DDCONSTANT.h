//
//  CONSTANT.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#ifndef IOSDuoduo_CONSTANT_h
#define IOSDuoduo_CONSTANT_h

/**
 *  Debug模式和Release模式不同的宏定义
 */

//-------------------打印--------------------
#ifdef DEBUG
#define NEED_OUTPUT_LOG             1
#define Is_CanSwitchServer          1
#else
#define NEED_OUTPUT_LOG             0
#define Is_CanSwitchServer          0
#endif

//#define DDLog(xx, ...)                      NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#define DDLog(xx,...)

#define IM_PDU_HEADER_LEN   16
#define IM_PDU_VERSION      1

//-------------------本地化--------------------
//在所有显示在界面上的字符串进行本地化处理
#define _(x)                                IMLocalizedString(x,@"")
#endif


