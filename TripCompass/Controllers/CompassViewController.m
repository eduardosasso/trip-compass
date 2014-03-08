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
  float GeoAngle;
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
  
  GeoAngle = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
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
    
    [self.compassImage layoutIfNeeded];
    
      self.compassImage.transform = CGAffineTransformMakeRotation((direction* M_PI / 180)+ GeoAngle);
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
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Checkpoint"
                                                   message:@"Save your current location to make sure you never get lost."
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK", nil];
  
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField * alertTextField = [alert textFieldAtIndex:0];
  alertTextField.placeholder = @"e.g: Ace Hotel New York";
  
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if([title isEqualToString:@"OK"]) {
    NSString *name = [alertView textFieldAtIndex:0].text;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    PlaceModel *placeModel = [NSEntityDescription insertNewObjectForEntityForName:@"PlaceModel" inManagedObjectContext:context];
    
    placeModel.name = name;
    placeModel.checkpoint = YES;
//    placeModel.area = @"Checkpoints";
    
    
    placeModel.lat = [NSNumber numberWithFloat:self.currentLocation.coordinate.latitude];
    placeModel.lng = [NSNumber numberWithFloat:self.currentLocation.coordinate.longitude];
    
    NSError *error;
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

  }
}

@end