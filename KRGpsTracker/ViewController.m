//
//  ViewController.m
//  KRGpsTracker V1.2
//
//  Created by Kalvar on 13/6/23.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize outMapView;
@synthesize outTrackingItem;
@synthesize outSpeedLabel;
@synthesize krGpsTracker = _krGpsTracker;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _krGpsTracker = [[KRGpsTracker alloc] init];
    self.krGpsTracker.mapView      = self.outMapView;
    self.krGpsTracker.trackingItem = self.outTrackingItem;
    [self.krGpsTracker initialize];
    
    //If you wanna use the IBOutlet in block method, that you need to use __block to declare a non-retain object to use.
    __block UILabel *_speedTextLabel         = self.outSpeedLabel;
    __block KRGpsTracker *_blockKrGpsTracker = self.krGpsTracker;
    
    //This infoHandler Block will happen in location changed.
    [self.krGpsTracker setChangeHandler:^(CGFloat meters, CGFloat seconds, CLLocation *location)
    {
        NSLog(@"meter : %f, seconds : %f, location : %f, %f", meters, seconds, location.coordinate.latitude, location.coordinate.longitude);
        //You can use here to show the speed info when gps distance has changed.
        //Here is the advice of default.
        //Over 3 seconds then to start in show.
        if( seconds > 3.0f )
        {
            [_speedTextLabel setText:[NSString stringWithFormat:@"%.2f mi/h", _blockKrGpsTracker.speedMilesPerHour]];
        }
    }];
    
    //This realTimeHandler Block will happen in every second. ( 1 second to fire once. )
    [self.krGpsTracker setRealTimeHandler:^(CGFloat meters, CGFloat seconds)
    {
        NSLog(@"meter : %f, seconds : %f", meters, seconds);
        //You can use here to show the speed info by each second changing.
        if( seconds > 5.0f )
        {
            //[_speedTextLabel setText:[NSString stringWithFormat:@"%.2f mi/h", _blockKrGpsTracker.speedMilesPerHour]];
        }
    }];
    
    //This headingHandler Block will happen in your touching the heading-button on the left-top of map.
    [self.krGpsTracker setHeadingHandler:^
    {
        //NSLog(@"You Click the Heading-Button on the Map Left-Top.");
    }];
    
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
