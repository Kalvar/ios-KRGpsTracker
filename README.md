## Screen Shot

<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRGpsTracker-1.png" alt="KRGpsTracker" title="KRGpsTracker" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRGpsTracker-2.png" alt="KRGpsTracker" title="KRGpsTracker" style="margin: 20px;" class="center" /> 

## How To Get Started

KRGpsTracker is a route tracker, it is like Nike+, RunKeeper that running tracker apps.

``` objective-c
#import "KRGpsTracker.h"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _krGpsTracker               = [[KRGpsTracker alloc] init];
    _krGpsTracker.mapView       = _outMapView;
    _krGpsTracker.trackingItem  = _outTrackingItem;
    _krGpsTracker.headingImage  = [UIImage imageNamed:@"arrow_heading.png"];
    _krGpsTracker.arrowImage    = [UIImage imageNamed:@"arrow_2.png"];
    _krGpsTracker.arrowThresold = 50.0f;
    [_krGpsTracker initialize];
    
    //If you wanna use the IBOutlet in block method, that you need to use __block to declare a non-retain object to use.
    __block UILabel *_speedTextLabel         = _outSpeedLabel;
    __block UILabel *_singalTextLabel        = _outGpsSingalLabel;
    __block KRGpsTracker *_blockKrGpsTracker = _krGpsTracker;
    
    //This infoHandler Block will happen in location changed.
    [_krGpsTracker setChangeHandler:^(CGFloat meters, CGFloat seconds, CLLocation *location)
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
    [_krGpsTracker setRealTimeHandler:^(CGFloat meters, CGFloat seconds)
    {
        NSLog(@"meter : %f, seconds : %f", meters, seconds);
        //You can use here to show the speed info by each second changing.
        if( seconds > 5.0f )
        {
            //[_speedTextLabel setText:[NSString stringWithFormat:@"%.2f mi/h", _blockKrGpsTracker.speedMilesPerHour]];
        }
    }];
    
    //This headingHandler Block will happen in your touching the heading-button on the left-top of map.
    [_krGpsTracker setHeadingHandler:^
    {
        //NSLog(@"You Click the Heading-Button on the Map Left-Top.");
    }];
    
    //This gpsSingalHandler Block will happen with in the location keep in changing.
    [_krGpsTracker setGpsSingalHandler:^(BOOL hasSingal, KRGpsSingalStrength singalStrength, CLLocation *location)
    {
        NSString *_singalText = [_blockKrGpsTracker catchLimitedGpsSingalStrengthStringWithLocation:location];
        [_singalTextLabel setText:_singalText];
        //... Others you wanna do.
        //...
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

#pragma --mark Extra Methods
-(void)resetGpsSingalStrength
{
    [self.outGpsSingalLabel setText:[self.krGpsTracker catchCurrentGpsSingalStrengthString]];
}

#pragma --mark IBActions
-(IBAction)toggleTracking:(id)sender
{
    if( _krGpsTracker.isTracking )
    {
        [_krGpsTracker stopTrackingWithCompletionHandler:^(CGFloat ranMeters, CGFloat ranKilometers, CGFloat ranMiles, CGFloat speedKilometersPerHour, CGFloat speedMilesPerHour) {
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
        [_krGpsTracker start];
    }
}

-(IBAction)resetMap:(id)sender
{
    [_krGpsTracker resetMap];
}

-(IBAction)selectMapMode:(id)sender
{
    //取得分割按鈕的個別按鈕索引 : 目前是哪一個按鈕被按下
    [_krGpsTracker selectMapMode:[sender selectedSegmentIndex]];
}

-(IBAction)hasGpsSingal:(id)sender
{
    NSString *_singalSituation = @"";
    BOOL _hasGpsSingal = [_krGpsTracker hasGpsSingal];
    if( _hasGpsSingal )
    {
        _singalSituation = @"Singal Alive.";
    }
    else
    {
        _singalSituation = @"Singal Disappear.";
    }
    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:@""
                                                         message:_singalSituation
                                                        delegate:nil
                                               cancelButtonTitle:@"Got It"
                                               otherButtonTitles:nil];
    [_alertView show];
}
```

## Version

V1.4.

## License

MIT.
