
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
#import "LoadingView.h"
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
  float directionPointing;
  float directionToGo;
  
  bool isGoingRightWay;
  bool isNearDestination;
  
  LoadingView *loadingView;
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
  self.compassImage.tintColor = customMagentaColor;

  nearbyAnimationRunning = FALSE;
  nearbyAnimationToggle = FALSE;
  
  [locationManager setHeadingFilter:.5];
  
  loadingView = [[LoadingView alloc] init];
  [self.navigationController.view addSubview:loadingView];
  
  //hide toolbar
  [self.tabBarController.tabBar setTranslucent:YES];
  [self.tabBarController.tabBar setHidden:YES];
  
  [self.navigationController.navigationBar setBackIndicatorImage:
   [UIImage imageNamed:@"icon_navbar_back"]];
  [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:
   [UIImage imageNamed:@"icon_navbar_back"]];
}

- (void)toggleLoadingView:(BOOL)visible showTip:(BOOL)tip {
    [loadingView setHidden:!visible];
    [self.view setHidden:visible];
    [loadingView.tipLabel setHidden:!tip];
    
    if (visible) [self.navigationController.view bringSubviewToFront:loadingView];
}

- (void)viewWillAppear:(BOOL)animated {
  //hide navigation bar bottom border
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];

  self.distanceLabel.textColor = customMagentaColor;
  
  [self toggleLoadingView:YES showTip:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
  //show navigation bar bottom border for other views when leaving
  [self.navigationController.navigationBar setShadowImage:nil];
  [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
  //show the tabbar back when changing screens
  [self.tabBarController.tabBar setHidden:NO];
  [self toggleLoadingView:NO showTip:NO];
}

#pragma mark Location Manager
- (void)startTrackingLocation {
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  locationManager.distanceFilter = 50;
  
  if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
  } else {
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Location services disabled"
                                                  message:@"Trip Compass needs access to your location. Please turn on Location Services in your device settings."
                                                 delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [alert show];
    
    
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.currentLocation = [locations lastObject];
  
  self.distanceLabel.text = [self.place formattedDistanceTo:self.currentLocation.coordinate];
  
  geoAngle = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
  
  // distance is returned in meters by default
  isNearDestination = [self.place distanceTo:self.currentLocation.coordinate] <= 180;
  NSTimer* nearbyTimer;
  if (isNearDestination) {
    nearbyTimer = [self nearbyTimerAnimation];
  } else {
    [nearbyTimer invalidate];
    self.distanceLabel.backgroundColor = [UIColor whiteColor];
    self.distanceLabel.textColor = currentColor;
  }
  
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading {
  if (newHeading.headingAccuracy > 0) {
    direction = -newHeading.trueHeading;
    directionToGo = (direction * M_PI / 180) + geoAngle;
    
    directionPointing = fabsf(geoAngle - fabsf((direction* M_PI / 180)));

    isGoingRightWay = directionPointing >= 0 && directionPointing <= 0.5;
    
    NSString *headingName = [NSString stringWithFormat:@"icon_%@.png", [Util getHeadingDirectionName:newHeading]];
    UIImage* logoImage = [UIImage imageNamed:[headingName lowercaseString]];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];

    currentColor = (isGoingRightWay || isNearDestination) ? customGreenColor : customMagentaColor;
    self.compassImage.tintColor = currentColor;
    self.distanceLabel.textColor = currentColor;
  
//    [self.compassImage layoutIfNeeded];
    
    //Move the compass to where you should go
    [UIView animateWithDuration:1 animations:^{
      self.compassImage.transform = CGAffineTransformMakeRotation(directionToGo);
    }];
    
    [self toggleLoadingView:NO showTip:NO];
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
  [self toggleLoadingView:YES showTip:YES];
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
  if([title isEqualToString:@"Ok"]) {
    [self.navigationController popViewControllerAnimated:YES];
  }
  
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
    
    int badgeValue = [[[super.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue intValue];
    ++badgeValue;
    [[super.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat: @"%d", badgeValue];
  }
}

@end