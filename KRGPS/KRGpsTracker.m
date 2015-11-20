//
//  KRGpsTracker.m
//  KRGpsTracker V1.4
//
//  Created by Kalvar on 13/7/7.
//  Copyright (c) 2013 - 2015年 Kuo-Ming Lin. All rights reserved.
//

#import "KRGpsTracker.h"

@interface KRGpsTracker ()

@property (nonatomic, strong) KRGpsTrackingView *trackingMapView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat keepTime;

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
    self.headingButton          = nil;
    self.runningSeconds         = 0.0f;
    self.changeHandler          = nil;
    self.headingHandler         = nil;
    self.timer                  = nil;
    self.keepTime               = 0.0f;
    self.arrowThresold          = 0.0f;
}

-(void)_remove
{
    self.isTracking  = NO;
    if( self.trackingMapView )
    {
        [self.trackingMapView removeFromSuperview];
        self.trackingMapView = nil;
    }
}

-(UIImage *)_imageNoCacheWithName:(NSString *)_imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _imageName]];
}

-(void)_headingButtonAction:(id)_sender
{
    // ... customize something you wanna do.
    if( self.headingHandler )
    {
        self.headingHandler();
    }
}

-(void)_makeHeadingIconButton
{
    if( self.headingButton )
    {
        if( self.headingButton.superview == self.mapView )
        {
            [self.headingButton removeFromSuperview];
        }
    }
    UIImage *_image    = self.headingImage;
    self.headingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.headingButton setFrame:CGRectMake(5.0f, 5.0f, _image.size.width, _image.size.height)];
    [self.headingButton setImage:_image forState:UIControlStateNormal];
    [self.headingButton addTarget:self
                           action:@selector(_headingButtonAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.headingButton];
}

#pragma --mark NSTimers
-(void)_keepCounting
{
    ++self.keepTime;
    if( self.realTimeHandler )
    {
        self.realTimeHandler(self.ranMeters, self.keepTime);
    }
}

-(void)_startTimer
{
    [self _stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(_keepCounting) userInfo:nil repeats:YES];
}

-(void)_stopTimer
{
    if( self.timer )
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.keepTime  = 0.0f;
}

@end

@implementation KRGpsTracker

+(instancetype)sharedTracker
{
    static dispatch_once_t pred;
    static KRGpsTracker *_singleton = nil;
    dispatch_once(&pred, ^{
        _singleton = [[KRGpsTracker alloc] init];
    });
    return _singleton;
}

-(instancetype)init
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
    _trackingMapView               = [[KRGpsTrackingView alloc] initWithFrame:_mapView.frame];
    _trackingMapView.superMapView  = _mapView;
    _trackingMapView.arrowThresold = _arrowThresold;
    _trackingMapView.arrowImage    = _arrowImage;
    
    //NSLog(@"self.subviews : %@", self.mapView.subviews);
    //將 trackingMapView 寫在 MapView 的觸碰控制層底下，這樣就能避免無法操作手勢的問題
    [[[_mapView subviews] objectAtIndex:0] addSubview:_trackingMapView];
    
    [self _makeHeadingIconButton];
    
    //設定 MapView 的委派
    _mapView.delegate          = _trackingMapView;
    //允許縮放地圖
    _mapView.zoomEnabled       = YES;
    //允許捲動地圖
    _mapView.scrollEnabled     = YES;
    //以小藍點顯示使用者目前的位置
    _mapView.showsUserLocation = YES;
    _locationManager           = [[CLLocationManager alloc] init];
    //For iOS 8
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [_locationManager requestAlwaysAuthorization]; //永久授權, For background access
        //[locationManager requestWhenInUseAuthorization]; //使用中授權, For foreground access
    }
    _locationManager.delegate  = self;
}

-(void)start
{
    //本來就是追蹤停止的狀態
    if( !_isTracking )
    {
        //加入蓋上來的 TrackingMapView
        //[self.mapView addSubview:trackingMapView];
        //設定為啟動追蹤
        _isTracking            = YES;
        _mapView.scrollEnabled = NO;
        _mapView.zoomEnabled   = NO;
        //iPhone 清醒中
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        _trackingItem.title    = _stopTrackingTitle;
        _ranMeters             = 0.0f;
        //取得追蹤初始時間
        _startDate             = [NSDate date];
        //設定定位的準確性 : 最高
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //開始定位
        [_locationManager startUpdatingLocation];
        //設定當使用者的位置超出 X 公尺後才呼叫其他定位方法 :: 預設為 kCLDistanceFilterNone
        _locationManager.distanceFilter = 10.0f;
        //設定方向過濾方式
        _locationManager.headingFilter  = kCLHeadingFilterNone;
        //啟動指南針方向定位
        [_locationManager startUpdatingHeading];
        //啟動計時
        [self _startTimer];
    }
}

-(void)initialStart
{
    [self initialize];
    [self start];
}

-(void)stop
{
    [self _stopTimer];
    _isTracking = NO;
    //啟動 iPhone 睡眠模式
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _trackingItem.title = _startTrackingTitle;
    //停止定位
    [_locationManager stopUpdatingLocation];
    //停止取得方位
    [_locationManager stopUpdatingHeading];
    //移除蓋上來的 TrackingMapView
    //[self._trackingMapView removeFromSuperview];
    //允許 MapView 被捲動
    _mapView.scrollEnabled  = YES;
    //允許 MapView 被縮放
    _mapView.zoomEnabled    = YES;
    CGFloat _time           = _runningSeconds;
    _ranKilometers          = _ranMeters / 1000;
    _ranMiles               = _ranMeters * 0.00062f;
    _speedKilometersPerHour = _ranMeters * 3.6f / _time;
    _speedMilesPerHour      = _ranMeters * 2.2369f / _time;
}

-(void)stopTrackingWithCompletionHandler:(KRGpsTrackerCompletionHandler)_completionHandler
{
    //正在 GPS 追蹤中
    if( _isTracking )
    {
        [self stop];
        if( _completionHandler )
        {
            _completionHandler(self.ranMeters, self.ranKilometers, self.ranMiles, self.speedKilometersPerHour, self.speedMilesPerHour);
        }
        if( _showCompletionAlert )
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
    [_trackingMapView reset];
}

-(void)selectMapMode:(MKMapType)selectedMapType
{
    switch (selectedMapType)
    {
        case 0:
            //標準模式
            _mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            //衛星圖象
            _mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            //混合圖象
            _mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

/*
 * @ 判斷 App 是否被允許運作於背景執行 ( 多工 )
 *   - Judges app allow running in the background.
 */
-(BOOL)isMultitaskingSupported
{
    return ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) ? [[UIDevice currentDevice] isMultitaskingSupported] : NO;
}

/*
 * @ 取得當前 GPS 訊號強度
 *   - Judge the GPS singal strength.
 */
-(KRGpsSingalStrength)singalStrength
{
    return [self singalStrengthWithLocation:self.locationManager.location];
}

/*
 * @ 取得指定 Location 的 GPS 訊號強度
 *   - Judge the Gps singal strength of limit location.
 */
-(KRGpsSingalStrength)singalStrengthWithLocation:(CLLocation *)_location
{
    //水平精度
    //CLLocationAccuracy horizontal = newLocation.horizontalAccuracy;
    //垂直精度
    //CLLocationAccuracy vertical = newLocation.verticalAccuracy;
    
    CLLocationAccuracy _horizontalAccuracy = _location.horizontalAccuracy;
    KRGpsSingalStrength _singalStrength    = KRGpsSingalStrengthNone;
    if( (_horizontalAccuracy > 0.0f) && (_horizontalAccuracy <= 10.0f) )
    {
        _singalStrength = KRGpsSingalStrengthPerfect;
    }
    else if( (_horizontalAccuracy > 10.0f) && (_horizontalAccuracy <= 30.0f) )
    {
        _singalStrength = KRGpsSingalStrengthStrong;
    }
    else if( (_horizontalAccuracy > 30.0f) && (_horizontalAccuracy <= 60.0f) )
    {
        _singalStrength = KRGpsSingalStrengthHigh;
    }
    else if( (_horizontalAccuracy > 60.0f ) && (_horizontalAccuracy <= 100.0f) )
    {
        _singalStrength = KRGpsSingalStrengthMiddle;
    }
    else if( (_horizontalAccuracy > 100.0f) && (_horizontalAccuracy <= 200.0f))
    {
        _singalStrength = KRGpsSingalStrengthLow;
    }
    return _singalStrength;
}

/*
 * @ 當前位置是否有 GPS 訊號
 *   - Is current location GPS singal alive ?
 */
-(BOOL)hasGpsSingal
{
    return !( [self singalStrength] == KRGpsSingalStrengthNone );
}

/*
 * @ 指定位置是否有 GPS 訊號
 *   - Is limited location GPS singal alive ?
 */
-(BOOL)hasGpsSingalWithLocation:(CLLocation *)_location
{
    return !( [self singalStrengthWithLocation:_location] == KRGpsSingalStrengthNone );
}

/*
 * @ 取得當前位置 GPS 訊號的字串
 *   - Catchs the GPS singal strength string.
 */
-(NSString *)catchCurrentGpsSingalStrengthString
{
    return [self catchLimitedGpsSingalStrengthStringWithLocation:self.locationManager.location];
}

/*
 * @ 取得指定位置 GPS 訊號的字串
 *   - Catchs the GPS singal strength string.
 */
-(NSString *)catchLimitedGpsSingalStrengthStringWithLocation:(CLLocation *)_location
{
    NSString *_gpsSingalString = @"No Singal";
    switch ( [self singalStrengthWithLocation:_location] )
    {
        case KRGpsSingalStrengthNone:
            //No Singal.
            //...
            break;
        case KRGpsSingalStrengthLow:
            //Low Singal.
            _gpsSingalString = @"Low Singal";
            break;
        case KRGpsSingalStrengthMiddle:
            //Middle Singal.
            _gpsSingalString = @"Middle Singal";
            break;
        case KRGpsSingalStrengthHigh:
            //High Singal.
            _gpsSingalString = @"High Singal";
            break;
        case KRGpsSingalStrengthStrong:
            //Strong Singal.
            _gpsSingalString = @"Strong Singal";
            break;
        case KRGpsSingalStrengthPerfect:
            //Perfect Singal. ( Almost Impossible )
            _gpsSingalString = @"Perfect Singal";
            break;
        default:
            break;
    }
    return _gpsSingalString;
}

/*
 * @ 取得指定區域的 GPS 訊號是否良好
 *   - Is the GPS single strength nice of limit location ?
 */
-(BOOL)isGpsNiceSingalWithLocation:(CLLocation *)_location
{
    return (_location.horizontalAccuracy <= 100.0f);
}

#pragma MapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //不需要任何的大頭針註解
    return nil;
}

/*
 * @ 這裡會在按下地圖進行移動時觸發
 *   - 每次點擊只會觸發 1 次，直到「放開手指，停止地圖移動時」，才會觸發 regionDidChangeAnimated 委派方法
 */
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
}

/*
 * @ 會在地圖移動結束時觸發
 *   - 在 regionWillChangeAnimated 完成後才會觸發
 */
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

#pragma CLLocationManagerDelegate
/*
 * @ 已更新 GPS 位置
 *   - 來自於啟動 [_locationManager startUpdatingLocation]; 會持續更新這裡，每秒 1 ~ 4 次不等，依當下的 GPS 訊號而定，
 *     可參考 Golf、 Sports、GpsTrakcer、MapKit
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation = [_trackingMapView getLastLocation];
    //加入一個新定位點
    [_trackingMapView addPoint:newLocation];
    
    //計算新舊位置的距離 ( 回傳公尺 )
    if( nil != oldLocation )
    {
        _ranMeters += [newLocation distanceFromLocation:oldLocation];
    }
    
    if( _changeHandler )
    {
        self.changeHandler(_ranMeters, self.runningSeconds, newLocation);
    }
    
    if( _gpsSingalHandler )
    {
        self.gpsSingalHandler( [self hasGpsSingal], [self singalStrength], newLocation );
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
    [_mapView setRegion:region animated:YES];
}

/*
 * @ 取得 GPS 羅盤方向 (以角度為單位，以順時針計算)
 *   - 正北方 0   度
 *   - 正東方 90  度
 *   - 正南方 180 度
 *   - 正西方 270 度
 *
 * @ 已更新 GPS 方向
 *   - 來自於啟動 [_locationManager startUpdatingHeading]; 會持續更新這裡的方向，
 *     可參考 GpsTrakcer
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //將真北的角度轉成弧度
    float rotation = newHeading.trueHeading * M_PI / 180;
    //依照指北針的角度同步旋轉 MapView 向北
    //也能放上一個指北針的圖，旋轉它就行
    if( _headingButton )
    {
        _headingButton.transform    = CGAffineTransformIdentity;
        CGAffineTransform transForm = CGAffineTransformMakeRotation(-rotation);
        _headingButton.transform    = transForm;
    }
    
    /*
    //動態變換整個地圖的顯示方向
    self.mapView.transform      = CGAffineTransformIdentity;
    CGAffineTransform transForm = CGAffineTransformMakeRotation(-rotation);
    self.mapView.transform      = transForm;
     */
    //[self.outMapView setNeedsDisplay];
}

//定位發生錯誤時觸發
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stop];
    //NSLog(@"LocationManager failed, The Error Code : %i \n", [error code]);
}

#pragma --mark Monitorings
/*
 * @ 已開始監控指定區域
 */
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    
}

/*
 * @ 失敗監控指定區域
 */
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
}

/*
 * @ 已暫停更新 GPS 定位
 *   - 當 GPS 定位被系統自動暫停時觸發
 */
-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    // ...
}

/*
 * @ 已重新啟動 GPS 定位
 *   - 當 GPS 定位被系統自動重啟時觸發
 */
-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    // ...
}

#pragma --mark Getter
-(CGFloat)ranKilometers
{
    return _ranMeters / 1000;
}

-(CGFloat)ranMiles
{
    return _ranMeters * 0.00062f;
}

-(CGFloat)speedKilometersPerHour
{
    return _ranMeters * 3.6f / self.runningSeconds;
}

-(CGFloat)speedMilesPerHour
{
    return _ranMeters * 2.2369f / self.runningSeconds;
}

-(CGFloat)runningSeconds
{
    return -[_startDate timeIntervalSinceNow];
}

-(BOOL)isGpsNice
{
    return (_locationManager.location.horizontalAccuracy <= 100.0f);
}


@end
