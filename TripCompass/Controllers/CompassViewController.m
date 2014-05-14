//
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

@interface CompassViewController () <CLLocationManagerDelegate, UIAlertViewDelegate>
  
@end

@implementation CompassViewController {
  CLLocationManager *locationManager;
  NSString *selectedLocation;
  float geoAngle;
  AppDelegate *appDelegate;
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
}

- (void)viewWillAppear:(BOOL)animated {
  //hide navigation bar bottom border
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
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
//    float magneticHeading = newHeading.magneticHeading;
    //float trueHeading = newHeading.trueHeading;
    
//    float heading = -1.0f * M_PI * magneticHeading / 180.0f;
    //image.transform = CGAffineTransformMakeRotation(heading);
//    self.compassImage.transform = CGAffineTransformScale(self.compassImage.transform, 0.5, 0.5);
//    self.compassImage.transform = CGAffineTransformMakeRotation(heading);
    

//      float bearing = [Util getHeadingForDirectionFromCoordinate:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
//      float bearing = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
//      float destinationHeading =  heading - bearing;
//      self.compassImage.transform = CGAffineTransformScale(self.compassImage.transform, 0.5, 0.5);
//    self.needleImage.transform = CGAffineTransformMakeRotation(destinationHeading);
      float direction = -newHeading.trueHeading;
    
//    self.compassImage.autoresizingMask = UIViewAutoresizingNone;
//     self.compassImage.center = self.view.center;
    
    NSString *directionName = [Util getHeadingDirectionName:newHeading];
    self.navigationItem.title = [NSString stringWithFormat:@"%@", directionName];
    
    [self.compassImage layoutIfNeeded];
    
//    NSLog(@"DIRECTION mpi : %f", direction);
    
//    DIRECTION mpi : -4.433422
//    ANGLE : 4.397930
    
    float orientationDirection = fabsf(geoAngle - fabsf((direction* M_PI / 180)));
    
    if (orientationDirection > 0 && orientationDirection < 0.30) {
      self.compassImage.tintColor = [UIColor greenColor];
      self.distanceLabel.textColor = [UIColor greenColor];
    } else {
      self.compassImage.tintColor = [UIColor redColor];
      self.distanceLabel.textColor = [UIColor redColor];
    }
    
    NSLog(@"DIRECTION mpi : %f", fabsf((direction* M_PI / 180)));
    NSLog(@"ANGLE : %f", geoAngle);
    
    self.compassImage.transform = CGAffineTransformMakeRotation((direction* M_PI / 180) + geoAngle);
    
  }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
  return YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//  TODO show message to detect gps is off
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