//
//  RFNetWorkAPIManager.h
//  GuoZhongBao
//
//  Created by baolicheng on 15/7/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFNetWorkHelper.h"
#import "JSONKit.h"
typedef enum{
    RegisterOperation = 1,
    LoginOperation,
    LoanOperation,
    upgradeCredit
} EagleeyeStrategyType;
@interface RFNetWorkAPIManager : NSObject
+(id)defaultManager;
//地理位置统计上报
-(void)submitLocationInfoWithUid:(NSString *)uid WithLocationList:(NSMutableArray *)locationList Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//获取地理位置上报策略
-(void)requestLocationModeSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;
@end
