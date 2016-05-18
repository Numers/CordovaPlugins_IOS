//
//  RFLocationServiceManager.m
//  CordovaDemo
//
//  Created by baolicheng on 15/8/5.
//
//

#import "RFLocationServiceManager.h"
#import "RFLocationEngine.h"
static RFLocationServiceManager *rfLocationServiceManager;
static RFLocationEngine *rfLocationEngine;
@implementation RFLocationServiceManager
+(id)defaultManager
{
    if (rfLocationServiceManager == nil) {
        rfLocationServiceManager = [[RFLocationServiceManager alloc] init];
    }
    return rfLocationServiceManager;
}

-(void)startServiceWithUid:(NSString *)uid WithToken:(NSString *)token
{
    if (rfLocationEngine) {
        [rfLocationEngine stopEngine];
    }else{
        rfLocationEngine = [[RFLocationEngine alloc] init];
    }
    
    [rfLocationEngine startEngineWithUid:uid WithToken:token];
}

-(void)stopService
{
    if (rfLocationEngine) {
        [rfLocationEngine stopEngine];
        rfLocationEngine = nil;
    }
}
@end
