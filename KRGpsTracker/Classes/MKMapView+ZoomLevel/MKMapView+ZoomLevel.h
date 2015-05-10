//
//  MKMapView+ZoomLevel.h
//  BiidealApp
//
//  Created by Kalvar on 2013/12/14.
//  Copyright (c) 2013年 PromptApps. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(double)zoomLevel
                   animated:(BOOL)animated;

- (double) getZoomLevel;

@end
