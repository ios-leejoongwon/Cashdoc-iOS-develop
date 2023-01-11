/*
 * Copyright (c) 2017-2019 KWIC Co., Ltd.
 * All rights reserved.
 */

#ifndef SmartAIBSDK_defines_h
#define SmartAIBSDK_defines_h


#define    SMARTAIB_VERSION_STRING @"3.2.43.2020111100"
#define    SMARTAIB_VERSION_NUMBER @"30243"

typedef enum : NSUInteger {
    KW_PLAIN_TEXT = 0,
    KW_SEED128,
    KW_NFILTER_FIXED,
    KW_NFILTER_VARIABLE,
    KW_MTRANSKEY_CIPHER_DATA,
    KW_MTRANSKEY_CIPHER_DATA_EX,
    KW_MTRANSKEY_CIPHER_DATA_EX_PADDING,
    KW_AES256BASE64_CBC_PKCS7,
    KW_RSA,
    KW_SEED128BASE64_FIXED,
    KW_KISA_SEED128_ECB_BASE64_2019,
    KW_AES128BASE64_CBC_PKCS5PADDING,
    KW_REPLACE,
    KW_MASKM,
    KW_MASKR,
    KW_AES256BASE64_CBC_PKCS5PADDING,
} KW_ENC_TYPE;

typedef enum : NSInteger {
    AIB_EV_COMPLETE = 1,
    AIB_EV_FAIL __attribute__((deprecated)),
    AIB_EV_CHATCA,
    AIB_EV_SMS,
    AIB_EV_SHOW_INFO,
    AIB_EV_HIDE_INFO,
    AIB_EV_MULTI_INPUT_DIALOG,
    AIB_EV_INTER_ACTION,
    AIB_EV_PROGRESS,
} KW_EV_TYPE;

typedef enum : NSInteger {
    /* iPhone or Simulator */
    KW_ENV_DEVICE = 1,
    /* Normal HTTP Server */
    KW_ENV_DEVICE_DEC,
    KW_ENV_LOCAL,
    KW_ENV_LOCAL_DEC,
    KW_ENV_TESTING,
    /* KWIC service server */
    KW_ENV_STAGING,
    KW_ENV_PRODUCTION
} KW_ENV_TYPE;

typedef enum : NSUInteger {
    /* KISA Seed128 ECB */
    KW_CIPHER_SEED128 = 1,
    /* NSHC nFilter */
    KW_CIPHER_KeyboardNFilter,
    /* Raonsecure mTranskey */
    KW_CIPHER_KeyboardMTranskey,
    KW_CIPHER_AES256BASE64,
    KW_CIPHER_RSA,
    KW_CIPHER_SEED128BASE64_FIXED,
    KW_CIPHER_KISA_SEED128_ECB_BASE64_2019,
    KW_CIPHER_AES128BASE64,
    KW_CIPHER_REPLACE,
    KW_CIPHER_MASKR,
    KW_CIPHER_MASKM,
} KW_CIPHER_TYPE;

typedef enum : NSUInteger {
    KW_PROGRESS_NONE = 0,
    KW_PROGRESS_ALL = 100,
} KW_PROGRESS_TYPE;

#endif /* SmartAIBSDK_defines_h */

