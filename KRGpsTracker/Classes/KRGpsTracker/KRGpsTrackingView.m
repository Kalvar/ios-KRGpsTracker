//
//  KRGpsTrackingView.m
//  KRGpsTracker V1.0
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
        
        //取得在 MapView 上的座標點
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
                UIImage *image = [self _imageNameNoCache:@"arrow.png"];
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
                //求出角度
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

-(void)addPoint:(CLLocation *)_point
{    
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
