//
//  KRGpsTracker.h
//  KRGpsTracker V1.0
//
//  Created by Kalvar on 13/7/7.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRGpsTrackingView.h"

typedef void (^TrackingCompleted)(CGFloat ranMeters, CGFloat ranKilometers, CGFloat ranMiles, CGFloat speedKilometersPerHour, CGFloat speedMilesPerHour);

@interface KRGpsTracker : NSObject<MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView *mapView;
    UIBarButtonItem *trackingItem;
    UIBarButtonItem *resetItem;
    BOOL isTracking;
    CLLocationManager *locationManager;
    NSDate *startDate;
    //GPS 羅盤
    CLHeading *heading;
    //開始與停止時的名稱
    NSString *startTrackingTitle;
    NSString *stopTrackingTitle;
    /*
     * @ 行進數據
     */
    //總共行進幾公尺
    CGFloat ranMeters;
    //總共行進幾公里
    CGFloat ranKilometers;
    //總共行進幾英哩
    CGFloat ranMiles;
    //行進時速( 公里 )
    CGFloat speedKilometersPerHour;
    //行進時速( 英哩 )
    CGFloat speedMilesPerHour;
    //在結束時秀出行進數據的 Alert
    BOOL showCompletionAlert;
    //指北針的按鈕
    UIButton *headingButton;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIBarButtonItem *trackingItem;
@property (nonatomic, strong) UIBarButtonItem *resetItem;
@property (nonatomic, assign) BOOL isTracking;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) CLHeading *heading;
@property (nonatomic, strong) NSString *startTrackingTitle;
@property (nonatomic, strong) NSString *stopTrackingTitle;
@property (nonatomic, assign) CGFloat ranMeters;
@property (nonatomic, assign) CGFloat ranKilometers;
@property (nonatomic, assign) CGFloat ranMiles;
@property (nonatomic, assign) CGFloat ranSpeed;
@property (nonatomic, assign) CGFloat speedKilometersPerHour;
@property (nonatomic, assign) CGFloat speedMilesPerHour;
@property (nonatomic, assign) BOOL showCompletionAlert;
@property (nonatomic, strong) UIButton *headingButton;


+(KRGpsTracker *)sharedManager;
-(void)initialize;
-(void)start;
-(void)initializeAndStart;
-(void)stop;
-(void)stopTrackingWithCompletionHandler:(TrackingCompleted)_completionHandler;
-(void)resetMap;
-(void)selectMapMode:(MKMapType)selectedMapType;
-(BOOL)isMultitaskingSupported;

@end
