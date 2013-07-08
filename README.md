## Screen Shot

<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRGpsTracker-1.png" alt="KRGpsTracker" title="KRGpsTracker" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRGpsTracker-2.png" alt="KRGpsTracker" title="KRGpsTracker" style="margin: 20px;" class="center" /> 

## Supports

KRGpsTracker supports ARC.

## How To Get Started

KRGpsTracker is a route tracker which records the route of running to show on MKMapView, and it can calculate the running info.

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

V1.0.

## License

MIT.

## Others

KRGpsTracker used an png image file of arrow from http://findicons.com/icon/202969/go_right, the image designed by deviantdark, thanks a lot. 