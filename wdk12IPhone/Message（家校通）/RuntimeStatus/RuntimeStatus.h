//
//  RuntimeStatus.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-31.
//  Copyright (c) 2014 dujia. All rights reserved.
//
#define TOPKEY @"fixedTop"
#import <Foundation/Foundation.h>
#import "DDUserEntity.h"
#import "std.h"
#define TheRuntime [RuntimeStatus instance]


NSString* ImageFullUrl(NSString* url);

@interface RuntimeStatus : NSObject

@property(strong)DDUserEntity *user;
@property(strong)NSMutableArray *isFixedArray;
@property(strong)NSString *sessionID;
@property(assign)int groupCount;

@property(copy)NSString *fastdfsupload;
@property(copy)NSString *fastdfsdownload;

@property(copy)NSString *token;
@property(copy)NSString *userID;
@property(strong)NSString *username;
@property(copy)NSString *dao;
@property(copy)NSString *pushToken;

+ (instancetype)instance;
-(void)insertToFixedTop:(NSString *)idString;
-(void)removeFromFixedTop:(NSString *)idString;
-(BOOL)isInFixedTop:(NSString *)idString;
-(NSUInteger)getFixedTopCount;
-(BOOL)isInShielding:(NSString *)idString;
-(void)removeIDFromShielding:(NSString *)idString;
-(void)addToShielding:(NSString *)string;
-(void)showAlertView:(NSString *)title Description:(NSString *)string;
-(void)updateData;
-(uint64_t)changeIDToOriginal:(NSString *)sessionID;
-(NSString *)changeOriginalToLocalID:(uint64_t)orignalID SessionType:(SessionType)sessionType;
#define LOCAL_MSG_BEGIN_ID 1000000
@end
