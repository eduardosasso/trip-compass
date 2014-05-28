
//  MainViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "CompassViewController.h"
#import "PlaceModel.h"
#import "Util.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface CompassViewController () <CLLocationManagerDelegate, UIAlertViewDelegate>
  
@end

@implementation CompassViewController {
  CLLocationManager *locationManager;
  NSString *selectedLocation;
  float geoAngle;
  AppDelegate *appDelegate;
  
  bool nearbyAnimationRunning;
  bool nearbyAnimationToggle;
  
  UIColor *currentColor;
  
  float direction;
  float orientationDirection;
  
  bool isGoingRightWay;
  bool isNearDestination;
  NSTimer* nearbyTimer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self startTrackingLocation];
  
  //Google Analytics
  self.screenName = @"CompassViewController";
  
  self.placeNameLabel.text = self.place.name;
  self.distanceLabel.text = @"";
  self.addressLabel.text = self.place.address;
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [appDelegate managedObjectContext];
  
  UIImage *img = [[self.compassImage image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.compassImage.image = img;
  self.compassImage.tintColor = [UIColor redColor];

  //hide toolbar
  [self.tabBarController.tabBar setTranslucent:YES];
  [self.tabBarController.tabBar setHidden:YES];
  
  nearbyAnimationRunning = FALSE;
  nearbyAnimationToggle = FALSE;
  
//  [locationManager setHeadingFilter:2];
}

- (void)viewWillAppear:(BOOL)animated {
  //hide navigation bar bottom border
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
  self.distanceLabel.textColor = customRedColor;
}

- (void)viewWillDisappear:(BOOL)animated {
  //show navigation bar bottom border for other views when leaving
  [self.navigationController.navigationBar setShadowImage:nil];
  [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
  //show the tabbar back when changing screens
  [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark Location Manager
- (void)startTrackingLocation {
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
  if( [CLLocationManager locationServicesEnabled] &&  [CLLocationManager headingAvailable]) {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
  } else {
    //TODO test this scenario. Upsell to enable location
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.currentLocation = [locations lastObject];
  
  self.distanceLabel.text = [self.place formattedDistanceTo:self.currentLocation.coordinate];
  
  geoAngle = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading {
  if (newHeading.headingAccuracy > 0) {
    direction = -newHeading.trueHeading;
    orientationDirection = fabsf(geoAngle - fabsf((direction* M_PI / 180)));

    isGoingRightWay = orientationDirection > 0 && orientationDirection < 0.30;
    
    //TODO move this to updatelocations and increase the distance on notifications
    // distance is returned in meters by default
    isNearDestination = [self.place distanceTo:self.currentLocation.coordinate] <= 150;

    self.navigationItem.title = [NSString stringWithFormat:@"%@", [Util getHeadingDirectionName:newHeading]];

    currentColor = (isGoingRightWay || isNearDestination) ? customGreenColor : customRedColor;
    self.compassImage.tintColor = currentColor;
    self.distanceLabel.textColor = currentColor;
  
    [self.compassImage layoutIfNeeded];
    
    //Move the compass to where you should go
    self.compassImage.transform = CGAffineTransformMakeRotation((direction * M_PI / 180) + geoAngle);

    if (isNearDestination) {
      nearbyTimer = [self nearbyTimerAnimation];
    } else {
      [nearbyTimer invalidate];
      self.distanceLabel.backgroundColor = [UIColor whiteColor];
      self.distanceLabel.textColor = currentColor;
    }
  }
}

- (NSTimer *)nearbyTimerAnimation {
  NSTimer* timer;
  if (!nearbyAnimationRunning) {
    nearbyAnimationRunning = TRUE;
    timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(30.0 / 60.0) target:self
                                                 selector:@selector(nearbyTimerAnimation:)
                                                 userInfo:nil
                                                  repeats:TRUE];
  }
  return timer;
}

- (void)nearbyTimerAnimation:(NSTimer *)timer {
  if (nearbyAnimationToggle) {
    self.distanceLabel.highlighted = true;
    self.distanceLabel.highlightedTextColor = [UIColor whiteColor];
    self.distanceLabel.backgroundColor = customGreenColor;
    nearbyAnimationToggle = false;
  } else {
    self.distanceLabel.highlighted = false;
    self.distanceLabel.backgroundColor = [UIColor whiteColor];
    nearbyAnimationToggle = true;
  }
  
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
  return YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  // TODO show message to detect gps is off
  NSLog(@"Can't report heading");
}

- (IBAction)checkpointAction:(id)sender {
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Checkpoint"
                                                   message:@"Where are you now?"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Save", nil];
  
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField * alertTextField = [alert textFieldAtIndex:0];
  alertTextField.placeholder = @"e.g: Hard to find state park";
  
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if([title isEqualToString:@"Save"]) {
    NSString *name = [alertView textFieldAtIndex:0].text;
    
    Place *place = [[Place alloc] init];
    place.key = [NSNumber numberWithInt:1];
    place.name = name;
    place.checkpoint = YES;
    place.lat = [NSNumber numberWithFloat:self.currentLocation.coordinate.latitude];
    place.lng = [NSNumber numberWithFloat:self.currentLocation.coordinate.longitude];
    place.city = @"Checkpoints";
    
    [place save];
  }
}

@end