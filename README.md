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

- (void)viewDidLoad
{
    [super viewDidLoad];
    krGpsTracker = [[KRGpsTracker alloc] init];
    self.krGpsTracker.mapView      = self.outMapView;
    self.krGpsTracker.trackingItem = self.outTrackingItem;
    [self.krGpsTracker initialize];

    //This infoHandler Block will happen in location changed.
    [self.krGpsTracker setChangeHandler:^(CGFloat meters, CGFloat seconds, CLLocation *location)
    {
         NSLog(@"meter : %f, seconds : %f, location : %f, %f", meters, seconds, location.coordinate.latitude, location.coordinate.longitude);
    }];
    
    //This realTimeHandler Block will happen in every second. ( 1 second to fire once. )
    [self.krGpsTracker setRealTimeHandler:^(CGFloat meters, CGFloat seconds)
    {
        NSLog(@"meter : %f, seconds : %f", meters, seconds);
    }];
    
    //This headingHandler Block will happen in your touching the heading-button on the left-top of map.
    [self.krGpsTracker setHeadingHandler:^
    {
        NSLog(@"You Click the Heading-Button on the Map Left-Top.");
    }];
    //self.krGpsTracker.resetItem;
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
    //取得分割按鈕的個別按鈕索引
    int index = [sender selectedSegmentIndex];
    [self.krGpsTracker selectMapMode:index];
}
```

## Version

V1.1.

## License

MIT.

## Others

KRGpsTracker used png image files of arrow from http://www.kenlaiweb.com/, the image designed by Kenlai Li, thanks a lot. 