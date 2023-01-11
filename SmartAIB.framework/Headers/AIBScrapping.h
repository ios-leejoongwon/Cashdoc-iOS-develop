/*
 * Copyright (c) 2017-2019 KWIC Co., Ltd.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SmartAIBSDK_defines.h"

@class AIBResult;
typedef void (^AIBResultHandler)(int resultCode, AIBResult *result);

/**
 * Represents a KWIC Scrapping.
 *
 * This class provides a scraapping configuration and result by KWIC input/output definition paper.
 */

@interface AIBScrapping : NSObject
{
@public
    AIBResult* _result;
}

@property (nonatomic, retain, readonly) NSMutableDictionary *inputEnc;
@property (nonatomic, retain, readonly) NSMutableDictionary *input;
@property (nonatomic, retain, readonly) NSMutableDictionary *outputEnc;
@property (nonatomic, retain, readonly) NSMutableArray *retryEcodeList;
@property (nonatomic, assign) BOOL isMonitoring; /* Monitoring report status on/off */
@property (nonatomic, assign) NSInteger pid; /* scraping process id */
@property (nonatomic, copy) AIBResultHandler resultHandler;
@property (nonatomic, retain, readonly) NSMutableDictionary *interActionDic;

@property (nonatomic) KW_PROGRESS_TYPE progressType;

/* Constructor */
- (id) initWithInput:(NSString *)input;
- (id) initWithInputDictionary:(NSDictionary *)input;
- (id) initWithInput:(NSString *)input onResult:(AIBResultHandler)handler;
- (id) initWithInputDictionary:(NSDictionary *)input onResult:(AIBResultHandler)handler;

- (void)setResult:(AIBResult *)result;
- (NSString *)registerRequestTime;
- (NSString *)registerResponseTime;
- (NSDictionary *)getInput;
- (void)setSessionId:(NSString *)sId;
- (void)setProgressEvent:(KW_PROGRESS_TYPE)type;

/* Give configuation for a scrapping. */
- (void)put:(NSString *)key string:(NSString *)value;
- (void)put:(NSString *)key data:(NSData *)value;


-(void)addRetryEcode:(NSString*)ecode count:(NSInteger)count;

/* Give encrypted configuation for a scrapping. */
- (void)putEnc:(NSString *)key
       encData:(NSData *)value
       encType:(KW_ENC_TYPE)type
        encKey:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION;
- (void)putEnc:(NSString *)key
     encString:(NSString *)value
       encType:(KW_ENC_TYPE)type
        encKey:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

- (void)putCertPwd:(NSData *)certPwd;

/* Encrypted output of scraping result. */
- (int)setOutPutEnc:(NSString *)field
       encType:(KW_ENC_TYPE)type
        encKey:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

- (int)setOutputFieldEnc:(NSString *)fieldPath encType:(KW_ENC_TYPE)type encKey:(NSString*)encKey iv:(NSString*)iv;

/* Decrypts encrypted string and combines strings to seed encryption and adds to input value. */
- (void)putCombine:(NSString *)field AIBCombines:(NSMutableArray *)combines key:(NSString *)key;

/* Make random key. */
- (BOOL)putEncStoredKey:(NSString*)field
               encValue:(NSString*)encValue
                encType:(KW_ENC_TYPE)encType
                  error:(NSError **)error;
- (NSString *)setSecureMode:(NSString *)mode securefield:(NSString*)securefield keydata:(NSString *)keydata;

/* InterAciton */
-(void)setInterActionTimeout:(NSString*)code timeout:(NSInteger)timeout;

/* Cancel */
-(void)cancel;

@end

@interface AIBScrapping (EncSwift)
/* For swift */
- (void)putEnc:(NSString *)key encData:(NSData *)value encType:(KW_ENC_TYPE)type encKeys:(NSArray*)list;
- (void)putEnc:(NSString *)key encString:(NSString *)value encType:(KW_ENC_TYPE)type encKeys:(NSArray*)list;
- (int)setOutPutEnc:(NSString *)field encType:(KW_ENC_TYPE)type encKeys:(NSArray*)list;
@end


