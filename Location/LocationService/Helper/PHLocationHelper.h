//
//  PHLocationHelper.h
//  PocketHealth
//
//  Created by macmini on 15-1-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@protocol PHLocationHelperDelegate <NSObject>
-(void)requestWeathInfoComplete:(float)mood WithPMValue:(float)pm;
@end
typedef enum{
    Mode_Time
}LocationStrategyEnum;
@interface PHLocationHelper : NSObject<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    NSMutableArray *locationList;
    NSTimer *timer;
    LocationStrategyEnum locationStrategyEnum;
    
    NSString *uid;
    NSString *token;
    LocationStrategyEnum modeTimeStrategy;
    LocationStrategyEnum modeLocationStrategy;
    float distanceFilter;
}
@property(nonatomic, assign) id<PHLocationHelperDelegate> delegate;

+(id)defaultHelper;
-(void)startUpdatingLocationWithStategyEnum:(LocationStrategyEnum)strategyEnum;
-(void)stopLocationWithUpload:(BOOL)upload;
-(void)uploadMyLocationInfoWithUid:(NSString *)myUid WithToken:(NSString *)myToken WithModeTimeStrategy:(LocationStrategyEnum)modeTime WithModeLocationStrategy:(LocationStrategyEnum)modeLocation WithDistanceFilter:(float)filter;
-(void)uploadAllLocationInfo;
@end
