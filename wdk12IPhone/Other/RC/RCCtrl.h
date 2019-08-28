//
//  RCCtrl.h
//  wdk12pad
//
//  Created by macapp on 15/12/30.
//  Copyright © 2015年 macapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourceVCViewController.h"
@interface RCCtrl : NSObject
@property (weak) ResourceVCViewController* vc;
@property NSString* path;
@property NSString* name;

+(id)initWithPath:(NSString*)path ConverPath:(NSString*)converpath Type:(NSString*)type Name:(NSString*)name VC:(ResourceVCViewController*)vc;
-(id)initWithVC:(ResourceVCViewController*)vc Path:(NSString*)path;

-(void)start;
-(void)end;
@end
