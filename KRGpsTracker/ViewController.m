//
//  ViewController.m
//  KRGpsTracker V1.0
//
//  Created by Kalvar on 13/6/23.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize outMapView;
@synthesize outToolStartTracking;
@synthesize krGpsTracker = _krGpsTracker;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _krGpsTracker = [[KRGpsTracker alloc] init];
    self.krGpsTracker.mapView      = self.outMapView;
    self.krGpsTracker.trackingItem = self.outToolStartTracking;
    [self.krGpsTracker initialize];
    //self.krGpsTracker.resetItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma My Methods
-(IBAction)toggleTracking:(id)sender
{
    if( self.krGpsTracker.isTracking )
    {
        [self.krGpsTracker stopTrackingWithCompletionHandler:^(CGFloat ranMeters, CGFloat ranKilometers, CGFloat ranMiles, CGFloat speedKilometersPerHour, CGFloat speedMilesPerHour) {
            NSString *message = [NSString stringWithFormat:@"Distance : %.02f km, %.02f mi.\nSpeed: %.02f km/h, %.02f mi/h",
                                 ranKilometers,
                                 ranMiles,
                                 speedKilometersPerHour,
                                 speedMilesPerHour];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Route Info."
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Yes"
                                                      otherButtonTitles: nil];
            
            [alertView show];
        }];
    }
    else
    {
        [self.krGpsTracker start];
    }
}

-(IBAction)resetMap:(id)sender
{
    [self.krGpsTracker resetMap];
}

-(IBAction)selectMapMode:(id)sender
{
    //取得分割按鈕的個別按鈕索引 : 目前是哪一個按鈕被按下
    int index = [sender selectedSegmentIndex];
    [self.krGpsTracker selectMapMode:index];
}


@end
