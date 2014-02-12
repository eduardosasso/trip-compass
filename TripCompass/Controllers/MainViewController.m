//
//  MainViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "MainViewController.h"
//#import "SearchViewController.h"
#import "PlaceModel.h"
#import "Util.h"
#import "AppDelegate.h"

@interface MainViewController () <CLLocationManagerDelegate, UIAlertViewDelegate>
  
@end

@implementation MainViewController {
  CLLocationManager *locationManager;
  NSString *selectedLocation;
  float GeoAngle;
  AppDelegate *appDelegate;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.screenName = @"Main";
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [appDelegate managedObjectContext];
  
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
  if( [CLLocationManager locationServicesEnabled] &&  [CLLocationManager headingAvailable]) {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    NSLog(@"Started");
  } else {
    NSLog(@"Can't report heading");
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.currentLocation = [locations lastObject];
  
  if (self.place) {
    self.navigationItem.title = self.place.name;
    self.navigationItem.prompt = [self.place formattedDistanceTo:self.currentLocation.coordinate];
    GeoAngle = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
  }
}

- (void)locationManager:(CLLocationManager*)manager
       didUpdateHeading:(CLHeading*)newHeading {
  
  if (newHeading.headingAccuracy > 0) {
    float magneticHeading = newHeading.magneticHeading;
//    float trueHeading = newHeading.trueHeading;
    
    float heading = -1.0f * M_PI * magneticHeading / 180.0f;
//    image.transform = CGAffineTransformMakeRotation(heading);
    self.compassImage.transform = CGAffineTransformScale(self.compassImage.transform, 0.5, 0.5);
    self.compassImage.transform = CGAffineTransformMakeRotation(heading);
    
    if (self.place) {
//      float bearing = [Util getHeadingForDirectionFromCoordinate:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
//      float bearing = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
//      float destinationHeading =  heading - bearing;
      self.needleImage.transform = CGAffineTransformScale(self.needleImage.transform, 0.5, 0.5);
//    self.needleImage.transform = CGAffineTransformMakeRotation(destinationHeading);
      float direction = -newHeading.trueHeading;  
      self.needleImage.transform = CGAffineTransformMakeRotation((direction* M_PI / 180)+ GeoAngle);
    }
  }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
//  TODO ENABLE this
//  return YES;
  return NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//  TODO show message to detect gps is off
  NSLog(@"Can't report heading");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  int searchTab = 0;
//  int favoritesTab = 1;
//
//  UITabBarController *tabBarController = (UITabBarController *)segue.destinationViewController;
//  UITabBarItem* search = [[[tabBarController tabBar] items] objectAtIndex:searchTab];
//  
//  if (appDelegate.isOnline) {
//    //default to search view if connected
//    search.badgeValue = nil;
//    tabBarController.selectedIndex = searchTab;
//    
//  } else {
//    //default to favorites view if offline
//    tabBarController.selectedIndex = favoritesTab;
//    
//    search.badgeValue = @"!";
//    
//    //[[[[tabBarController tabBar] items] objectAtIndex:searchTab]setEnabled:FALSE];
//  }
//}

- (IBAction)checkpointAction:(id)sender {
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Checkpoint" message:@"Save your current location to make sure you never get lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
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
    placeModel.area = @"Checkpoints";
    
    
    placeModel.lat = [NSNumber numberWithFloat:self.currentLocation.coordinate.latitude];
    placeModel.lng = [NSNumber numberWithFloat:self.currentLocation.coordinate.longitude];
    
    NSError *error;
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

  }
}

@end
