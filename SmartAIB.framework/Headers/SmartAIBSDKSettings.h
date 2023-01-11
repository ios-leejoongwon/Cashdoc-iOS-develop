/*
 * Copyright (c) 2017-2019 KWIC Co., Ltd.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface SmartAIBSDKSettings : NSObject

@property (nonatomic, retain) NSDictionary *config;
@property (nonatomic, copy, readonly) NSString *accessKey;
@property (nonatomic, copy, readonly) NSString *sharedKey;

- (id)initWithKey:(NSString *)accessKey sharedKey:(NSString *)shared_key;

/* Give global configuation for a SmartAIBSDK. */
- (void)set:(NSString *)key int:(NSInteger)value;
- (void)set:(NSString *)key string:(NSString *)value;

- (void)set:(NSString *)key value:(NSString *)value __deprecated; /* deprecated */
@end
