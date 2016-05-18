//
//  RFNetWorkAPIManager.m
//  GuoZhongBao
//
//  Created by baolicheng on 15/7/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFNetWorkAPIManager.h"
#import "Location.h"
static RFNetWorkAPIManager *rfNetWorkAPIManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation RFNetWorkAPIManager
+(id)defaultManager
{
    if (rfNetWorkAPIManager == nil) {
        rfNetWorkAPIManager = [[RFNetWorkAPIManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        requestManager.requestSerializer.timeoutInterval = TimeOut;
    }
    return rfNetWorkAPIManager;
}

-(void)submitLocationInfoWithUid:(NSString *)uid WithLocationList:(NSMutableArray *)locationList Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;
{
    NSMutableString *jsonStr = [NSMutableString stringWithString:@"["];
    for (Location *m in locationList) {
        if ([m isEqual:[locationList lastObject]]) {
            NSString *str = [NSString stringWithFormat:@"{\"location\":\"%f,%f\",\"time\":%.0f,\"mode_id\":\"%ld\"}",m.lat,m.lng,m.time,(long)m.modelId];
            [jsonStr appendString:str];
        }else{
            NSString *str = [NSString stringWithFormat:@"{\"location\":\"%f,%f\",\"time\":%.0f,\"mode_id\":\"%ld\"},",m.lat,m.lng,m.time,(long)m.modelId];
            [jsonStr appendString:str];
        }
    }
    [jsonStr appendString:@"]"];
    [locationList removeAllObjects];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"user_id",jsonStr,@"json_data",nil];
    NSString *url = [NSString stringWithFormat:@"%@%@",API_GZB,API_LocationInfoUpload];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [requestManager POST:encodeUrl parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        NSInteger status = [[jsonData objectForKey:@"status"] integerValue];
        if (status == 200) {
            success(operation,responseObject);
        }else{
            error(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(operation, error);
    }];

}

-(void)requestLocationModeSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",API_GZB,API_LocationModeRequest];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:@"ios",@"client", nil];
    [requestManager GET:encodeUrl parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        NSInteger status = [[jsonData objectForKey:@"status"] integerValue];
        if (status == 200) {
            success(operation,responseObject);
        }else{
            error(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(operation, error);
    }];
}
@end
