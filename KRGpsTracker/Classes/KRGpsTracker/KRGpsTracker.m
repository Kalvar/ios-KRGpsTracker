//
//  KRGpsTracker.m
//  KRGpsTracker V1.0
//
//  Created by Kalvar on 13/7/7.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRGpsTracker.h"

@interface KRGpsTracker ()

@property (nonatomic, strong) KRGpsTrackingView *_trackingMapView;

@end

@interface KRGpsTracker (fixPrivate)

-(void)_initWithVars;
-(void)_remove;

@end

@implementation KRGpsTracker (fixPrivate)

-(void)_initWithVars
{
    self.startTrackingTitle     = @"Start Tracking";
    self.stopTrackingTitle      = @"Stop Tracking";
    self.ranMeters              = 0.0f;
    self.ranMiles               = 0.0f;
    self.ranKilometers          = 0.0f;
    self.speedKilometersPerHour = 0.0f;
    self.speedMilesPerHour      = 0.0f;
    self.showCompletionAlert    = NO;
}

-(void)_remove
{
    self.isTracking  = NO;
    if( self._trackingMapView )
    {
        [self._trackingMapView removeFromSuperview];
        self._trackingMapView = nil;
    }
}

@end

@implementation KRGpsTracker

@synthesize mapView;
@synthesize trackingItem;
@synthesize resetItem;
@synthesize isTracking;
@synthesize locationManager;
@synthesize startDate;
@synthesize heading;
@synthesize startTrackingTitle;
@synthesize stopTrackingTitle;
@synthesize ranMeters = _ranMeters;
@synthesize ranKilometers;
@synthesize ranMiles;
@synthesize ranSpeed;
@synthesize speedKilometersPerHour;
@synthesize speedMilesPerHour;
@synthesize showCompletionAlert;
//
@synthesize _trackingMapView;

+(KRGpsTracker *)sharedManager
{
    static dispatch_once_t pred;
    static KRGpsTracker *_singleton = nil;
    dispatch_once(&pred, ^{
        _singleton = [[KRGpsTracker alloc] init];
        [_singleton _initWithVars];
    });
    return _singleton;
    //return [[self alloc] init];
}

-(id)init
{
    self = [super init];
    if( self )
    {
        [self _initWithVars];
    }
    return self;
}

#pragma Methods
-(void)initialize
{
    [self _remove];
    _trackingMapView = [[KRGpsTrackingView alloc] initWithFrame:self.mapView.frame];
    _trackingMapView.superMapView = self.mapView;
    //NSLog(@"self.subviews : %@", self.mapView.subviews);
    [[[self.mapView subviews] objectAtIndex:0] addSubview:_trackingMapView];
    //[self.mapView addSubview:_trackingMapView];
    //設定 MapView 的委派
    self.mapView.delegate          = self._trackingMapView;
    //允許縮放地圖
    self.mapView.zoomEnabled       = YES;
    //允許捲動地圖
    self.mapView.scrollEnabled     = YES;
    //以小藍點顯示使用者目前的位置
    self.mapView.showsUserLocation = YES;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
}

-(void)start
{
    //本來就是追蹤停止的狀態
    if( !isTracking )
    {
        //加入蓋上來的 TrackingMapView
        //[self.mapView addSubview:trackingMapView];
        //設定為啟動追蹤
        isTracking = YES;
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled   = NO;
        //iPhone 清醒中
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        self.trackingItem.title = self.stopTrackingTitle;
        _ranMeters = 0.0f;
        //取得追蹤初始時間
        startDate = [NSDate date];
        //設定定位的準確性 : 最高
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //開始定位
        [locationManager startUpdatingLocation];
        //設定當使用者的位置超出 X 公尺後才呼叫其他定位方法 :: 預設為 kCLDistanceFilterNone
        locationManager.distanceFilter = 10.0f;
        //設定方向過濾方式
        locationManager.headingFilter = kCLHeadingFilterNone;
        //啟動指南針方向定位
        [locationManager startUpdatingHeading];
    }
}

-(void)initializeAndStart
{
    [self initialize];
    [self start];
}

-(void)stop
{
    isTracking = NO;
    //啟動 iPhone 睡眠模式
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.trackingItem.title = self.startTrackingTitle;
    //停止定位
    [locationManager stopUpdatingLocation];
    //停止取得方位
    [locationManager stopUpdatingHeading];
    //移除蓋上來的 TrackingMapView
    //[self._trackingMapView removeFromSuperview];
    //允許 MapView 被捲動
    self.mapView.scrollEnabled = YES;
    //允許 MapView 被縮放
    self.mapView.zoomEnabled   = YES;
    CGFloat _time = -[startDate timeIntervalSinceNow];
    self.ranKilometers          = _ranMeters / 1000;
    self.ranMiles               = _ranMeters * 0.00062f;
    self.speedKilometersPerHour = _ranMeters * 3.6f / _time;
    self.speedMilesPerHour      = _ranMeters * 2.2369f / _time;
}

-(void)stopTrackingWithCompletionHandler:(TrackingCompleted)_completionHandler
{
    //正在 GPS 追蹤中
    if( isTracking )
    {
        [self stop];
        _completionHandler(self.ranMeters, self.ranKilometers, self.ranMiles, self.speedKilometersPerHour, self.speedMilesPerHour);
        if( self.showCompletionAlert )
        {
            NSString *_message = [NSString stringWithFormat:@"Distance : %.02f km, %.02f mi.\nSpeed: %.02f km/h, %.02f mi/h",
                                  self.ranKilometers,
                                  self.ranMiles,
                                  self.speedKilometersPerHour,
                                  self.speedMilesPerHour];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Route Info."
                                                                message:_message
                                                               delegate:self
                                                      cancelButtonTitle:@"Yes"
                                                      otherButtonTitles: nil];
            
            [alertView show];
        }
    }
}

-(void)resetMap
{
    [self._trackingMapView reset];
}

-(void)selectMapMode:(MKMapType)selectedMapType
{
    switch (selectedMapType)
    {
        case 0:
            //標準模式
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            //衛星圖象
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            //混合圖象
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

/*
 * @ 判斷 App 是否被允許運作於背景執行 ( 多工 )
 *   - Judges app allow running in background.
 */
-(BOOL)isMultitaskingSupported
{
    BOOL _isSupported = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        _isSupported = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return _isSupported;
}

#pragma MapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //不需要任何的大頭針註解
    return nil;
}

#pragma CLLocationManagerDelegate
//當使用者取得新的地理位置資訊後觸發
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //加入一個新定位點
    [_trackingMapView addPoint:newLocation];
    
    //計算新舊位置的距離 ( 回傳公尺 )
    if(oldLocation != nil)
    {
        _ranMeters += [newLocation distanceFromLocation:oldLocation];
    }
    
    /*
     * @ 指定顯示區域
     *
     * @ 單位
     *   - 經度每差 0.01 大約實際距離是 1.024 公里
     *   - 緯度每差 0.01 大約實際距離是 1.112 公里
     */
    //製作一個圍繞在新座標點中心的區域 ( 500 公尺 x 500 公尺 的範圍 )
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    //製作一個圍繞在新區域中心的定位區域
    MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, span);
    [self.mapView setRegion:region animated:YES];
}

/*
 * 取得 GPS 羅盤方向 (以角度為單位，以順時針計算) : 正北方 0 度 / 正東方 90 度 / 正南方 180 度 / 正西方 270 度
 */
//當 CLLocationManager 取得更新後的方向資訊時觸發
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //將真北的角度轉成弧度
    float rotation = newHeading.trueHeading * M_PI / 180;
    //動態變換整個地圖的顯示方向
    self.mapView.transform      = CGAffineTransformIdentity;
    CGAffineTransform transForm = CGAffineTransformMakeRotation(-rotation);
    self.mapView.transform      = transForm;
    //[self.outMapView setNeedsDisplay];
}

//定位發生錯誤時觸發
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stop];
    NSLog(@"LocationManager failed, The Error Code : %i \n", [error code]);
}

@end
