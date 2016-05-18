/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVLocation.h"
#import "RFLocationServiceManager.h"
#import <Cordova/CDV.h>

@implementation CDVLocation
-(void)startLocationService:(CDVInvokedUrlCommand*)command
{
    currentCallBackId = command.callbackId;
    NSDictionary *dic = [command argumentAtIndex:0];
    if (dic) {
        NSString *uid = [dic objectForKey:@"uid"];
        NSString *token = [dic objectForKey:@"token"];
        if (uid) {
            [[RFLocationServiceManager defaultManager] startServiceWithUid:uid WithToken:token];
            [self successWithCallbackID:currentCallBackId withMessage:@"启动定位完成"];
        }else{
            [self failWithCallbackID:currentCallBackId withMessage:@"Json字符串Key-value键值对有问题!"];
        }
    }
    
}

-(void)postLocationStrategy:(CDVInvokedUrlCommand*)command
{
    currentCallBackId = command.callbackId;
    NSDictionary *dic = [command argumentAtIndex:0];
    if (dic) {
        NSString *strategy = [dic objectForKey:@"strategy"];
        if (strategy) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationStrategyNotificationName" object:nil userInfo:dic];
            [self successWithCallbackID:currentCallBackId withMessage:@"发送策略完成"];
        }else{
            [self failWithCallbackID:currentCallBackId withMessage:@"Json字符串Key-value键值对有问题!"];
        }
    }
}

-(id)objectFromJsonString:(NSString *)jsonString
{
    if (!jsonString)
    {
        [self failWithCallbackID:currentCallBackId withMessage:@"参数格式错误"];
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id params = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableContainers
                                                  error:&err];
    
    if (err)
    {
        [self failWithCallbackID:currentCallBackId withMessage:@"参数格式错误"];
        return nil;
    }
    return params;
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [commandResult setKeepCallback:[NSNumber numberWithInteger:1]];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [commandResult setKeepCallback:[NSNumber numberWithInteger:1]];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}
@end
