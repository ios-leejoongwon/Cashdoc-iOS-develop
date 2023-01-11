/*
 * Copyright (c) 2017-2019 KWIC Co., Ltd.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SmartAIBSDK_defines.h"

@interface AIBResult : NSObject
{
@public
    NSString *_cpatchaText;
    NSString *_smsText;
    NSArray *_inputs;
}

@property (nonatomic, copy) NSString *fCode;
@property (nonatomic, copy) NSString *module;
@property (nonatomic, copy) NSString *customer;
@property (nonatomic, assign, readonly)KW_EV_TYPE resultCode;
@property (nonatomic, retain) NSDictionary *outputEnc;
@property (nonatomic, retain) NSMutableArray *outputEncFileds;
@property (nonatomic, assign) NSInteger pid; /* scraping process id */

@property (nonatomic, retain, readonly)NSString *mShowInfoKey;
@property (nonatomic, retain, readonly)NSString *mShowInfoMsg;
@property (nonatomic, retain, readonly)NSString *mShowInofData;

- (instancetype)initWithResult:(NSString *)result;
- (instancetype)initWithImageData:(NSData *)data;
- (instancetype)initWithError:(NSDictionary *)errorInfo;
- (instancetype)initWithShowInfo:(NSString*)key msg:(NSString*)msg data:(NSString*)data;
- (instancetype)initWithHideInfo:(NSString*)key;
- (instancetype)initWithInterAction:(NSString*)code param:(NSString*)param;
- (instancetype)initWithProgressMessage:(NSString*)msg state:(NSString*)state;

- (void)make;
/* Return the result of scripping as json format */
- (NSString *)getResult;
/* Set captcha value */
- (void)setCaptcha:(NSString *)value;
/* Return the result of captcha */
- (NSData *)getCaptcha;
/* Set SMS value */
- (void)setSMSText:(NSString *)value;
/* Return titles and types for dialog */
- (NSArray *)getMultiInputDialogSubTitles;
- (NSArray *)getMultiInputDialogSubInputTypes;
/* Set dialog values */
- (NSString *)setMultiInputDialogResult:(NSArray *)inputs;
/* Cancel to input */
- (void)setMultiInputDialogCancel;

/* Get BankSign value */
- (NSString *)getShowInfoKey;
- (NSString *)getShowInfoMsg;
- (NSString *)getShowInfoData;

/* InterAction */
-(NSString*)getInterActionCode;
-(NSString*)getInterActionParam;
-(void)setInterActionReturn:(NSString*)value;
/* ProgressMessage */
-(NSString*)getProgressMessage;
-(NSString*)getProgressState;
@end
