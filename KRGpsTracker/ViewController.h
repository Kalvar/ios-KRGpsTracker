//
//  ViewController.h
//  KRGpsTracker V1.4
//
//  Created by Kalvar on 13/6/23.
//  Copyright (c) 2013 - 2015年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRGpsTracker.h"

@interface ViewController : UIViewController
{    
    
}

@property (nonatomic, weak) IBOutlet MKMapView *outMapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *outTrackingItem;
@property (nonatomic, weak) IBOutlet UILabel *outSpeedLabel;
@property (nonatomic, weak) IBOutlet UILabel *outGpsSingalLabel;
@property (nonatomic, strong) KRGpsTracker *krGpsTracker;

-(void)resetGpsSingalStrength;

-(IBAction)toggleTracking:(id)sender;
-(IBAction)resetMap:(id)sender;
-(IBAction)selectMapMode:(id)sender;
-(IBAction)hasGpsSingal:(id)sender;

@end