//
//  ViewController.h
//  KRGpsTracker V1.0
//
//  Created by Kalvar on 13/6/23.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRGpsTracker.h"

@interface ViewController : UIViewController
{    
    
}

@property (nonatomic, weak) IBOutlet MKMapView *outMapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *outToolStartTracking;
@property (nonatomic, strong) KRGpsTracker *krGpsTracker;

-(IBAction)toggleTracking:(id)sender;
-(IBAction)resetMap:(id)sender;
-(IBAction)selectMapMode:(id)sender;

@end