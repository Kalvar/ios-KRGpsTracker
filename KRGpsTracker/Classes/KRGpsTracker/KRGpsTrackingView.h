//
//  KRGpsTrackingView.h
//  KRGpsTracker V1.1
//
//  Created by Kalvar on 13/7/7.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface KRGpsTrackingView : UIView<MKMapViewDelegate>
{
    //儲存使用者所有拜訪過的地圖點( Visited Points )
    NSMutableArray *visitedPoints;
    MKMapView *superMapView;
    CGFloat arrowThresold;
}

@property (nonatomic, strong) NSMutableArray *visitedPoints;
@property (nonatomic, strong) MKMapView *superMapView;
@property (nonatomic, assign) CGFloat arrowThresold;

//新增一個拜訪點到 points 裡
-(void)addPoint:(CLLocation *)_point;
//重設 MapView
-(void)reset;

@end
