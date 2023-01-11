//
//  SmartAIBSDKEx.h
//  SmartAIB-Dynamic
//
//  Created by KwicJoe의 Macbook Pro on 2020/03/25.
//  Copyright © 2020 KWIC. All rights reserved.
//

#import "SmartAIBSDK.h"
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface SmartAIBSDKEx : NSObject

/* Single scrapping launcher */
+ (void)run:(AIBScrapping *)sp;
/* Multi scrapping launcher */
+ (void)runMulti:(NSArray *)scrapings
      onProgress:(onProgress)onProgress
        onResult:(onResult)onResult
         timeout:(NSInteger)timeout; /* mesec */

@end

NS_ASSUME_NONNULL_END
