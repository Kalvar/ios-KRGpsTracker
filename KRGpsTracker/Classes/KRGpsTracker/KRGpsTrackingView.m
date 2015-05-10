//
//  KRGpsTrackingView.m
//  KRGpsTracker V1.3
//
//  Created by Kalvar on 13/7/7.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRGpsTrackingView.h"
#import <MapKit/MKMapView.h>

@interface KRGpsTrackingView (fixPrivate)

-(void)_initWithVars;
-(UIImage *)_imageNameNoCache:(NSString *)_imageName;

@end

@implementation KRGpsTrackingView (fixPrivate)

-(void)_initWithVars
{
    //清除背景色
    self.backgroundColor = [UIColor clearColor];
    //初始化 visitedPoints
    visitedPoints        = [[NSMutableArray alloc] init];
    self.superMapView    = nil;
    //預設箭頭在距離多少公尺時出現
    self.arrowThresold   = 50.0f;
}

-(UIImage *)_imageNameNoCache:(NSString *)_imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _imageName]];
}

@end

@implementation KRGpsTrackingView

@synthesize visitedPoints;
@synthesize superMapView;
@synthesize arrowThresold = _arrowThresold;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _initWithVars];
    }
    return self;
}

//繪製移動路線和箭頭
-(void)drawRect:(CGRect)rect
{
    if( [visitedPoints count] <= 1 || self.hidden )
    {
        return;
    }
    
    if( !self.superMapView )
    {
        self.superMapView = (MKMapView *)self.superview;
    }
    
    //取得當前的座標線形圖形內容 ( 畫布內容 )
    CGContextRef context = UIGraphicsGetCurrentContext();
    //設定路線寬度
    CGContextSetLineWidth(context, 4.0);
    //座標點
    CGPoint point;
    //距離
    float distance = 0.0;
    
    int pointsCount = [visitedPoints count];
    
#error Todo : 直線夌角，圓滑直線問題 ( 圖資的資料來源座標 CGPoints .... )，或寫一個路徑演算法來判斷大眾的區間走法解決。
#error Todo : GPS Tracker 的省電問題 <---- O3O ( 利用十秒存活期來, 9 秒存活計劃，或採取間隔法，每 5 秒啟動更新，每次更新 10 秒，因考慮還有背景存活問題，每次間隔必須小於 10 秒採取 9 秒存活計劃，才能保證 GPS 活躍，請參考 KRBle 的 Scan 模式，加入 TImeout 和 Interval 間隔等 )
#error Todo : 採用區域監控的模式，來把每一個監控點連結起來，現在這支 Code 也是 50 公尺才記錄一個點並連結，因此，用 Monitoring 是合理可省電和達到效果的，但必須判斷要監控的範圍如果小於 25 公尺 ( 或 5 公尺 ? 5 公尺是較精確的，但須驗證 )，就不採用監控模式來畫點和線，而是採用原模式，以不斷更新 GPS 的方式來畫點和線
    
    for(int i=0; i<pointsCount; i++)
    {
        float f = (float) i;
        //線條顏色
        CGContextSetRGBStrokeColor(context,
                                   0,
                                   1 - f / ( pointsCount - 1 ),
                                   f / ( pointsCount - 1 ),
                                   0.8);
        
        //取得下一個　Location 定位
        CLLocation *nextLocation = [visitedPoints objectAtIndex:i];
        CGPoint lastPoint = point;
        
        //從下一個經緯度來換算取得在 MapView 上的座標點
        point = [self.superMapView convertCoordinate:nextLocation.coordinate toPointToView:self];
        //如果這不是第一個點
        if( i != 0 )
        {
            //移動至最後一個點
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
            //新增一條路線
            CGContextAddLineToPoint(context, point.x, point.y);
            //距離 = 乘冪(次方)計算( 這裡 2 次方 )後開平方根
            distance += sqrtf( pow(point.x - lastPoint.x, 2) + pow(point.y - lastPoint.y, 2) );
            //如果距離大於預設的長度
            if( distance >= _arrowThresold )
            {
                //開始繪製路線與箭頭
                UIImage *image = [self _imageNameNoCache:@"arrow_2.png"];
                CGPoint middle = CGPointMake((point.x + lastPoint.x) / 2,
                                             (point.y + lastPoint.y) / 2);
                CGRect frame = CGRectMake( ( middle.x - image.size.width / 2 ),
                                           ( middle.y - image.size.height / 2 ),
                                           image.size.width,
                                           image.size.height );
                CGContextSaveGState(context);
                CGContextTranslateCTM(context,
                                      frame.origin.x + frame.size.width / 2,
                                      frame.origin.y + frame.size.height / 2);
                
                //求出角度 ( 也能記錄起來備用 )
                float _angle = atanf( ( point.y - lastPoint.y ) / ( point.x - lastPoint.x ) );
                if( point.x < lastPoint.x )
                {
                    _angle += 3.14159;
                }
                //畫弧線
                CGContextRotateCTM(context, _angle);
                CGContextDrawImage(context,
                                   CGRectMake(-frame.size.width / 2,
                                              -frame.size.height / 2,
                                              frame.size.width,
                                              frame.size.height),
                                   image.CGImage);
                CGContextRestoreGState(context);
                distance = 0.0f;
            }
        }
        //畫出路徑
        CGContextStrokePath(context);
    }
}

/*
 * @ 2013.10.03 筆記
 *   - 要能完整重現整個跑過的路線，需要將每一個點的經緯度資訊( CLLocation ) 完整記錄至 SQLite ( 或 Server ) 上，
 *     因為這裡每一個 Point 都是 CLLocation，而參數值的型態如下所示 : 
 *
         CLLocation *_loc = [[CLLocation alloc] initWithCoordinate:_point.coordinate
                                                          altitude:_point.altitude
                                                horizontalAccuracy:_point.horizontalAccuracy
                                                  verticalAccuracy:_point.verticalAccuracy
                                                            course:_point.course
                                                             speed:_point.speed
                                                         timestamp:_point.timestamp];
 *
 *     _point.coordinate         = CLLocationCoordinate2D ; double ; latitude & longitude
 *     _point.altitude           = CLLocationDistance     ; double
 *     _point.horizontalAccuracy = CLLocationAccuracy     ; double
 *     _point.verticalAccuracy   = CLLocationAccuracy     ; double
 *     _point.course             = CLLocationDirection    ; double
 *     _point.speed              = CLLocationSpeed        ; double
 *     _point.timestamp          = NSDate
 *
 */
-(void)addPoint:(CLLocation *)_point
{
    //檢查是否與上一個記錄點不相等
    CLLocation *lastPoint = [visitedPoints lastObject];
    if( _point.coordinate.latitude != lastPoint.coordinate.latitude || _point.coordinate.longitude != lastPoint.coordinate.longitude )
    {
        [visitedPoints addObject:_point];
        //重繪 View
        [self setNeedsDisplay];
    }
}

-(void)reset
{
    [visitedPoints removeAllObjects];
    [self setNeedsDisplay];
}

#pragma MKMapViewDelegate
//當範圍將被改變時觸發
-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    self.hidden = YES;
}

//當範圍完成改變時觸發
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.hidden = NO;
    [self setNeedsDisplay];
}




@end
