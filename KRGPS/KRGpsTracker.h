//
//  KRGpsTracker.h
//  KRGpsTracker V1.4
//
//  Created by Kalvar on 13/7/7.
//  Copyright (c) 2013 - 2015年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRGpsTrackingView.h"

typedef enum KRGpsSingalStrength
{
    //No Singal
    KRGpsSingalStrengthNone = 0,
    //Low Singal
    KRGpsSingalStrengthLow,
    //Middle Singal
    KRGpsSingalStrengthMiddle,
    //High Singal
    KRGpsSingalStrengthHigh,
    //Strong Singal
    KRGpsSingalStrengthStrong,
    //Perfect Singal ( Almost Impossible. )
    KRGpsSingalStrengthPerfect
}KRGpsSingalStrength;

typedef void (^KRGpsTrackerCompletionHandler)(CGFloat ranMeters, CGFloat ranKilometers, CGFloat ranMiles, CGFloat speedKilometersPerHour, CGFloat speedMilesPerHour);
typedef void (^KRGpsTrackerRealTimeHandler)(CGFloat meters, CGFloat seconds);
typedef void (^KRGpsTrackerInfoHandler)(CGFloat meters, CGFloat seconds, CLLocation *location);
typedef void (^KRGpsTrackerGpsSingalHandler)(BOOL hasSingal, KRGpsSingalStrength singalStrength, CLLocation *location);


@interface KRGpsTracker : NSObject<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIBarButtonItem *trackingItem;
@property (nonatomic, strong) UIBarButtonItem *resetItem;
@property (nonatomic, assign) BOOL isTracking;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *startDate;
//GPS 羅盤
@property (nonatomic, strong) CLHeading *heading;
//開始與停止時的名稱
@property (nonatomic, strong) NSString *startTrackingTitle;
@property (nonatomic, strong) NSString *stopTrackingTitle;
//總共行進幾公尺
@property (nonatomic, assign) CGFloat ranMeters;
//總共行進幾公里
@property (nonatomic, assign) CGFloat ranKilometers;
//總共行進幾英哩
@property (nonatomic, assign) CGFloat ranMiles;
@property (nonatomic, assign) CGFloat ranSpeed;
//行進時速( 公里 )
@property (nonatomic, assign) CGFloat speedKilometersPerHour;
//行進時速( 英哩 )
@property (nonatomic, assign) CGFloat speedMilesPerHour;
//在結束時秀出行進數據的 Alert
@property (nonatomic, assign) BOOL showCompletionAlert;
//指北針的按鈕
@property (nonatomic, strong) UIButton *headingButton;
//運行時間
@property (nonatomic, assign) CGFloat runningSeconds;

@property (nonatomic, copy) void (^changeHandler)(CGFloat meters, CGFloat seconds, CLLocation *location);
@property (nonatomic, copy) void (^realTimeHandler)(CGFloat meters, CGFloat seconds);
@property (nonatomic, copy) void (^headingHandler)(void);
@property (nonatomic, copy) void (^gpsSingalHandler)(BOOL hasSingal, KRGpsSingalStrength singalStrength, CLLocation *location);

@property (nonatomic, assign) BOOL isGpsNice;
@property (nonatomic, strong) UIImage *headingImage;
@property (nonatomic, assign) float arrowThresold;
@property (nonatomic, strong) UIImage *arrowImage;

+(instancetype)sharedTracker;
-(void)initialize;
-(void)start;
-(void)initialStart;
-(void)stop;
-(void)stopTrackingWithCompletionHandler:(KRGpsTrackerCompletionHandler)_completionHandler;
-(void)resetMap;
-(void)selectMapMode:(MKMapType)selectedMapType;
-(BOOL)isMultitaskingSupported;
-(KRGpsSingalStrength)singalStrength;
-(KRGpsSingalStrength)singalStrengthWithLocation:(CLLocation *)_location;
-(BOOL)hasGpsSingal;
-(BOOL)hasGpsSingalWithLocation:(CLLocation *)_location;
-(NSString *)catchCurrentGpsSingalStrengthString;
-(NSString *)catchLimitedGpsSingalStrengthStringWithLocation:(CLLocation *)_location;
-(BOOL)isGpsNiceSingalWithLocation:(CLLocation *)_location;

@end
