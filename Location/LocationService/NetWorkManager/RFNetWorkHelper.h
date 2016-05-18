//
//  RFNetWorkHelper.h
//  renrenfenqi
//
//  Created by baolicheng on 15/6/29.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#ifndef renrenfenqi_RFNetWorkHelper_h
#define renrenfenqi_RFNetWorkHelper_h
#import "AFNetworking.h"
#define TimeOut 10.0f

#define ISTEST 1
//test switch 0:production 1:test

#if ISTEST
//test
#define API_GZB                         @"http://api.gzb.renrenfenqi.com/"
#define API_REDPACKET                   @"http://test.h5.guozhongbao.com/activity/redpacket/display.html"
#define ShareURL   @"http://test.h5.guozhongbao.com/activity/redpacket/share.html?offline&"
#else
//production
#define API_GZB                         @"http://api.guozhongbao.com/"
#define API_REDPACKET                   @"http://h5.guozhongbao.com/activity/redpacket/display.html"
#define ShareURL   @"http://h5.guozhongbao.com/activity/redpacket/share.html?"
//#define API_GZB                         @"http://api.gzb.renrenfenqi.com/"
#endif

//地理位置上报
/*********************************************************************/
#define API_LocationInfoUpload @"location/Reported"
#define API_LocationModeRequest @"location/mode"
/*********************************************************************/
typedef void (^ApiSuccessCallback)(AFHTTPRequestOperation*operation, id responseObject);
typedef void (^ApiErrorCallback)(AFHTTPRequestOperation*operation, id responseObject);
typedef void (^ApiFailedCallback)(AFHTTPRequestOperation*operation, NSError *error);
#endif
