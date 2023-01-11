/*
 * Copyright (c) 2017-2019 KWIC Co., Ltd.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SmartAIBSDK_defines.h"



@interface AIBCombineInputInfo : NSObject

@property (nonatomic, retain) NSString * _Nullable valueString;
@property (nonatomic, retain) NSData * _Nullable valueData;
@property (nonatomic, assign) KW_ENC_TYPE encType;
@property (nonatomic, retain) NSArray * _Nullable keys;


- (instancetype _Nullable)initWithString:(NSString * _Nullable)valueString
                       encType:(KW_ENC_TYPE)type
                       encyKey:(NSString * _Nullable)firstKey, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype _Nullable)initWithData:(NSData * _Nullable)valueData
                     encType:(KW_ENC_TYPE)type
                     encyKey:(NSString * _Nullable)firstKey, ... NS_REQUIRES_NIL_TERMINATION;
@end

@interface AIBCombineInputInfo (Swift)
- (instancetype _Nullable)initWithString:(NSString * _Nullable)valueString encType:(KW_ENC_TYPE)type encKeys:(NSArray* _Nullable)list;
- (instancetype _Nullable)initWithData:(NSData * _Nullable)valueData encType:(KW_ENC_TYPE)type encKeys:(NSArray* _Nullable)list;
@end



