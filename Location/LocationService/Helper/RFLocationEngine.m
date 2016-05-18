//
//  RFLocationEngine.m
//  GuoZhongBao
//
//  Created by baolicheng on 15/7/27.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFLocationEngine.h"
#import "RFNetWorkAPIManager.h"
#import "LocationStrategy.h"
#import "PHLocationHelper.h"

static NSString *notificationName = @"LocationStrategyNotificationName";
@implementation RFLocationEngine
-(void)startEngineWithUid:(NSString *)myUid WithToken:(NSString *)myToken
{
    uid = myUid;
    token = myToken;
    if (!uid) {
        return;
    }
    
    if (!notificationList) {
        [self registerNotify];
        isCheckComplete = NO;
        notificationList = [[NSMutableArray alloc] init];
    }
    
    if (!isCheckComplete) {
        [self checkLocationStrategy];
    }else{
        [self beginStartLocation];
    }
}

-(void)registerNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptNotification:) name:notificationName object:nil];
}

-(void)checkLocationStrategy
{
    [[RFNetWorkAPIManager defaultManager] requestLocationModeSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if (resultDic) {
            NSArray *dataArr = [resultDic objectForKey:@"data"];
            if (dataArr) {
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                for (NSDictionary *m in dataArr) {
                    LocationStrategy *locationStrategy = [[LocationStrategy alloc] initWithDic:m];
                    [arr addObject:locationStrategy];
                }
                
                if (arr && arr.count > 0) {
                    strategyList = [NSArray arrayWithArray:arr];
                }
                [self beginStartLocation];
                isCheckComplete = YES;
                [self executeNotify];
            }
        }
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        isCheckComplete = NO;
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        isCheckComplete = NO;
    }];
}

-(void)beginStartLocation
{
    LocationStrategy *location = [self searchStrategyWithCode:@"location_env"];
    LocationStrategy *modeTime = [self searchStrategyWithCode:@"time_env"];
    if (location && modeTime) {
        [[PHLocationHelper defaultHelper] uploadMyLocationInfoWithUid:uid WithToken:token WithModeTimeStrategy:(LocationStrategyEnum)modeTime.modeId WithModeLocationStrategy:(LocationStrategyEnum)location.modeId WithDistanceFilter:[location.cName floatValue]];
    }
}

-(LocationStrategy *)searchStrategyWithModeId:(NSInteger)modeId
{
    LocationStrategy *locationStrategy = nil;
    if (strategyList) {
        for (LocationStrategy *m in strategyList) {
            if (m.subStrategy.modeId == modeId) {
                locationStrategy = m.subStrategy;
            }
        }
    }
    return locationStrategy;
}

-(LocationStrategy *)searchStrategyWithCode:(NSString *)code
{
    LocationStrategy *locationStrategy = nil;
    if (strategyList) {
        for (LocationStrategy *m in strategyList) {
            if ([m.code isEqualToString:code]) {
                locationStrategy = m.subStrategy;
            }
        }
    }
    return locationStrategy;
}

-(void)executeNotify
{
    if (isCheckComplete) {
        if (strategyList) {
            LocationStrategy *strategy = [self searchStrategyWithCode:@"location_env"];
            if (strategy) {
                if (strategy.isState == 2) {
                    [self stopEngine];
                }
                
                if (strategy.isState == 1) {
                    if (notificationList && notificationList.count > 0) {
                        for (NSDictionary *m in notificationList) {
                            LocationStrategyEnum strategyEnum = (LocationStrategyEnum)[[m objectForKey:@"strategy"] integerValue];
                            LocationStrategy *postLocationStrategy = [self searchStrategyWithModeId:strategyEnum];
                            if (postLocationStrategy && postLocationStrategy.isState == 1) {
                                [[PHLocationHelper defaultHelper] startUpdatingLocationWithStategyEnum:strategyEnum];
                            }
                        }
                        [notificationList removeAllObjects];
                    }
                }
            }
        }
    }
}

-(void)stopEngine
{
    [[PHLocationHelper defaultHelper] stopLocationWithUpload:NO];
    if (notificationList) {
        [notificationList removeAllObjects];
        notificationList = nil;
        isCheckComplete = NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)acceptNotification:(NSNotification *)notify
{
    id userInfo = [notify userInfo];
    if (userInfo) {
        [notificationList addObject:userInfo];
        [self executeNotify];
    }
}
@end