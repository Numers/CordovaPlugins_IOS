//
//  PHLocationHelper.m
//  PocketHealth
//
//  Created by macmini on 15-1-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHLocationHelper.h"
#import "Location.h"
#import "RFNetWorkAPIManager.h"
#define TimeInterval 60*60
#define LoadMaxCount 10
#define UPLOADCOUNT @"UPLOADLOCATIONCOUNT"
static PHLocationHelper *phLocationHelper;
static NSArray *timeArr;
@implementation PHLocationHelper
+(id)defaultHelper
{
    if (phLocationHelper == nil) {
        phLocationHelper = [[PHLocationHelper alloc] init];
        timeArr = @[@"7",@"9",@"11",@"13",@"15",@"17",@"19",@"21",@"23",@"2",@"5"];
    }
    return phLocationHelper;
}

-(void)startLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = distanceFilter;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [locationManager requestAlwaysAuthorization];
    }
    locationManager.pausesLocationUpdatesAutomatically = NO;
//    [locationManager startUpdatingLocation];
    [self fireDateFromCurrentTime];
}

-(void)startUpdatingLocation
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger hour = [dateComponent hour];
    if ([timeArr containsObject:[NSString stringWithFormat:@"%ld",(long)hour]]) {
        if (locationManager) {
            locationStrategyEnum = modeTimeStrategy;
            [locationManager startUpdatingLocation];
        }
    }
}

-(void)fireDateFromCurrentTime
{
    NSTimeInterval nextHour = [[NSDate date] timeIntervalSince1970] + 3600.0f;
    NSDate *nextHourDate = [NSDate dateWithTimeIntervalSince1970:nextHour];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:nextHourDate];
    dateComponent.minute = 0;
    dateComponent.second = 0;
    
    NSDate *fireDate = [calendar dateFromComponents:dateComponent];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    timer = [[NSTimer alloc] initWithFireDate:fireDate interval:TimeInterval target:self selector:@selector(startUpdatingLocation) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    [timer fire];
}

-(void)startUpdatingLocationWithStategyEnum:(LocationStrategyEnum)strategyEnum
{
    if (locationManager) {
        locationStrategyEnum = strategyEnum;
        [locationManager startUpdatingLocation];
    }
}

-(void)uploadMyLocationInfoWithUid:(NSString *)myUid WithToken:(NSString *)myToken WithModeTimeStrategy:(LocationStrategyEnum)modeTime WithModeLocationStrategy:(LocationStrategyEnum)modeLocation WithDistanceFilter:(float)filter;
{
    uid = myUid;
    token = myToken;
    modeTimeStrategy = modeTime;
    modeLocationStrategy = modeLocation;
    distanceFilter = filter;
    if (!uid) {
        return;
    }
    
    if (![self shouldUpload]) {
        return;
    }
    
    if(timer){
        [timer invalidate];
        timer = nil;
    }
    
    if (locationManager) {
        [locationManager stopUpdatingLocation];
        locationManager = nil;
    }
    
    if ([CLLocationManager locationServicesEnabled]){
        if (locationList == nil) {
            locationList = [[NSMutableArray alloc] init];
        }
        [self startLocation];
    }
}

-(BOOL)shouldUpload
{
    if (uid) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *today = [NSDate date];
        NSString *todayStr = [formatter stringFromDate:today];
        NSString *key = [NSString stringWithFormat:@"%@_%@_%@",UPLOADCOUNT,uid,todayStr];
        id count = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (count == nil) {
            return YES;
        }else{
            NSInteger loadCount = [count integerValue];
            if (loadCount < LoadMaxCount) {
                return YES;
            }else{
                return NO;
            }
        }
        return YES;
    }else{
        return NO;
    }
}

-(void)uploadAllLocationInfo
{
    if (!uid) {
        return;
    }
    
    if (![self shouldUpload]) {
        return;
    }
    
    if ((locationList) && (locationList.count > 0)) {
        [[RFNetWorkAPIManager defaultManager] submitLocationInfoWithUid:uid WithLocationList:locationList Success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *today = [NSDate date];
            NSString *todayStr = [formatter stringFromDate:today];
            NSString *key = [NSString stringWithFormat:@"%@_%@_%@",UPLOADCOUNT,uid,todayStr];
            id count = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if (count == nil) {
                NSNumber *uploadCount = [NSNumber numberWithInteger:1];
                [[NSUserDefaults standardUserDefaults] setObject:uploadCount forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else{
                NSInteger loadCount = [count integerValue];
                loadCount ++;
                NSNumber *num = [NSNumber numberWithInteger:loadCount];
                [[NSUserDefaults standardUserDefaults] setObject:num forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (loadCount < LoadMaxCount) {
                    
                }else{
                    [self stopLocationWithUpload:NO];
                }
            }
        } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

-(void)stopLocationWithUpload:(BOOL)upload
{
    if (upload) {
        [self uploadAllLocationInfo];
    }else{
        [locationList removeAllObjects];
        locationList = nil;
    }
    
    if (locationManager) {
        [locationManager stopUpdatingLocation];
    }
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma -mark CLLocaitonManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
//    if (status == kCLAuthorizationStatusNotDetermined) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您未选择定位服务,可到设置中进行设置。" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    if (location.horizontalAccuracy == -1) {
        [manager stopUpdatingLocation];
        [timer invalidate];
        timer = nil;
        [self startLocation];
    }else{
        if (locationList.count > 0) {
            if (locationStrategyEnum == modeTimeStrategy) {
                //上传locationlist里面的位置信息
                [self uploadAllLocationInfo];
            }
        }
        NSLog(@"%.2f,%.2f",location.coordinate.latitude,location.coordinate.longitude);
        Location *curLocation = [[Location alloc] init];
        curLocation.lat = location.coordinate.latitude;
        curLocation.lng = location.coordinate.longitude;
        curLocation.time = [[NSDate date] timeIntervalSince1970];
        curLocation.modelId = locationStrategyEnum;
        [locationList addObject:curLocation];
        if (locationStrategyEnum != modeLocationStrategy) {
            locationStrategyEnum = modeLocationStrategy;
        }
//        [manager stopUpdatingLocation];
        
//        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
//            if (array.count > 0) {
//                CLPlacemark *placemark = [array objectAtIndex:0];
//                NSString *locality = placemark.locality;
//                if (!locality) {
//                    //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
//                    locality = placemark.administrativeArea;
//                }
//                NSString *state = placemark.administrativeArea;
//                NSString *area = placemark.subLocality;
//                
//            }
//        }];
    }
}

//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation
//{
//    
//}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        //访问被拒绝
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
    }
    [manager stopUpdatingLocation];
}
@end
