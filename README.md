## Screen Shot

<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRGpsTracker-1.png" alt="KRGpsTracker" title="KRGpsTracker" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRGpsTracker-2.png" alt="KRGpsTracker" title="KRGpsTracker" style="margin: 20px;" class="center" /> 

## Supports

KRGpsTracker supports ARC.

## How To Get Started

KRGpsTracker is a route tracker which records the route of running to show on MKMapView, it can calculate the running info and show it on real-time.

``` objective-c
#import "KRGpsTracker.h"

@property (nonatomic, strong) KRGpsTracker *krGpsTracker;

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
    __block UILabel *_singalTextLabel        = self.outGpsSingalLabel;
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
    
    //This gpsSingalHandler Block will happen with in the location keep in changing.
    [self.krGpsTracker setGpsSingalHandler:^(BOOL hasSingal, KRGpsSingalStrength singalStrength, CLLocation *location)
    {
        NSString *_singalText = [_blockKrGpsTracker catchLimitedGpsSingalStrengthStringWithLocation:location];
        [_singalTextLabel setText:_singalText];
        //... Others you wanna do.
        //...
    }];

}

#pragma --mark Extra Methods
-(void)resetGpsSingalStrength
{
    [self.outGpsSingalLabel setText:[self.krGpsTracker catchCurrentGpsSingalStrengthString]];
}

#pragma --mark IBActions
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

-(IBAction)hasGpsSingal:(id)sender
{
    NSString *_singalSituation = @"";
    BOOL _hasGpsSingal = [self.krGpsTracker hasGpsSingal];
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

V1.3.

## License

MIT.

## Others

KRGpsTracker used png image files of arrow from http://www.kenlaiweb.com/, the image designed by Kenlai Li, thanks a lot. 