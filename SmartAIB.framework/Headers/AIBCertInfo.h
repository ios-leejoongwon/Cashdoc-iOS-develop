/*
 * Copyright (c) 2017-2019 KWIC Co., Ltd.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface AIBCertInfo : NSObject
{
@protected
    NSString* _certDirectory;
    NSString* _subjectDN;
    NSString* _issureDN;
    NSString* _notBefore;
    NSString* _notAfter;
    NSString* _policy;
    NSString* _serialString;
    unsigned int _serialNumbrer;
}


@property (nonatomic, retain, readonly) NSString* certDirectory;
@property (nonatomic, retain, readonly) NSString* subjectDN;
@property (nonatomic, retain, readonly) NSString* issureDN;
@property (nonatomic, retain, readonly) NSString* notBefore;
@property (nonatomic, retain, readonly) NSString* notAfter;
@property (nonatomic, retain, readonly) NSString* policy;
@property (nonatomic, retain, readonly) NSString* serialString;
@property (nonatomic, assign, readonly) unsigned int serialNumbrer __deprecated;

@end






