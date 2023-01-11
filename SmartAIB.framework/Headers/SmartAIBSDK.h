/*
 * Copyright (c) 2017-2019 KWIC Co., Ltd.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SmartAIBSDK_defines.h"
#import "AIBResult.h"
#import "AIBScrapping.h"
#import "AIBCertInfo.h"
#import "SmartAIBSDKSettings.h"
#import "AIBCombineInputInfo.h"
#ifdef KW_SMARTRAW
#import "SmartRaw.h"
#endif

/* For multi */
typedef void (^onProgress)(int resultCode, AIBResult *result);
typedef void (^onResult)(NSArray *aibResults);

/**
 * Launcher class of scrappings.
 */
@interface SmartAIBSDK : NSObject

/* Initialize scrapping engine with SmartAIBSDKSettings */
+ (void)initialize:(SmartAIBSDKSettings *)config;
+ (void)initialize:(SmartAIBSDKSettings *)config env:(KW_ENV_TYPE)type;

/* Single scrapping launcher */
+ (void)run:(AIBScrapping *)sp;
/* Multi scrapping launcher */
+ (void)runMulti:(NSArray *)scrapings
      onProgress:(onProgress)onProgress
        onResult:(onResult)onResult
         timeout:(NSInteger)timeout; /* mesec */

/* Certification infomation */
+ (AIBCertInfo *)CertInfo:(NSString *)cert_directory;
+ (AIBCertInfo *)CertInfoWithDERData:(NSData *)derData;
+ (NSArray *)CertInfoList:(NSString *)base_cert_directory;
+ (NSString *)getCertAuthorityName:(NSString *)oid;
+ (NSString *)getCertType:(NSString *)oid;

/* Generate key for mTrans */
+ (NSData*)putMtransKeyToStore:(NSArray *)fields length:(NSInteger)length;

/* Split key */
+ (NSString *)splitKey:(NSString *)orignalKey onResult:(AIBResultHandler)handler;
/* Merge key */
+ (NSString *)mergeKey:(NSString *)first second:(NSString *)second onResult:(AIBResultHandler)handler;

/* RSA */
+ (NSData *)generateRSAPublicKey:(NSString *)tag;
+ (NSString *)generateRSAkeyByBase64:(NSString *)tag;

@end

@interface SmartAIBHelpper : NSObject

/* Convert string from data type for MTrans keyboard security*/
+ (NSString *)NSDataToHex:(NSData *)data;
+ (NSString *)NSDataToRHex:(NSData *)data;
+ (NSData *)HexToData:(NSString *)paramString;
/* Verify that certificaiton and password are valid */
+ (BOOL)isValidCertPassword:(NSString *)certPath certPassword:(NSString *)pwd;
+ (BOOL)isValidCertPassword:(NSData *)signCert signPri:(NSData *)signPri certPassword:(NSString *)pwd;

+ (NSData *)encryptByRSA:(NSString *)plain publicKey:(NSData *)publicKey;
+ (NSData *)decryptByRSA:(NSString *)encryption tag:(NSString *)tag;

@end
