
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
  NSTimer *searchTimer;
  bool animationRunning;
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
  
  animationRunning = FALSE;
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
    float direction = -newHeading.trueHeading;
    NSString *directionName = [Util getHeadingDirectionName:newHeading];
    self.navigationItem.title = [NSString stringWithFormat:@"%@", directionName];
    
    [self.compassImage layoutIfNeeded];
    
    float orientationDirection = fabsf(geoAngle - fabsf((direction* M_PI / 180)));
    
    UIColor *previousTintColor = self.compassImage.tintColor;
    
    if (orientationDirection > 0 && orientationDirection < 0.30) {
      self.compassImage.tintColor = customGreenColor;
      self.distanceLabel.textColor = customGreenColor;
    } else {
      self.compassImage.tintColor = customRedColor;
      self.distanceLabel.textColor = customRedColor;
    }
    
    if (![previousTintColor isEqual:self.compassImage.tintColor]) {
      CATransition *transitionAnimation = [CATransition animation];
      [transitionAnimation setType:kCATransitionFade];
      [transitionAnimation setDuration:0.2f];
      [self.compassImage.layer addAnimation:transitionAnimation forKey:@"fadeAnimation"];
//      [self.distanceLabel.layer addAnimation:transitionAnimation forKey:@"fadeAnimation"];
      
//      UIColor *color = self.distanceLabel.textColor;
//      self.distanceLabel.layer.shadowColor = [color CGColor];
//      self.distanceLabel.layer.shadowRadius = 4.0f;
//      self.distanceLabel.layer.shadowOpacity = .9;
//      self.distanceLabel.layer.shadowOffset = CGSizeZero;
//      self.distanceLabel.layer.masksToBounds = NO;
    }
    

    self.distanceLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
//    UILabel *originalDistanceLabel = self.distanceLabel;
    // distance is returned in meters by default
//    if ([self.place distanceTo:self.currentLocation.coordinate] <= 150) {
    
//      [UIView animateWithDuration:2.0 animations:^{
//        self.distanceLabel.layer.backgroundColor = [UIColor greenColor].CGColor;
//      } completion:NULL];
//    self.distanceLabel.layer.backgroundColor = customGreenColor.CGColor;
//    self.distanceLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
//    self.distanceLabel.layer.cornerRadius = 3;
//    self.distanceLabel.layer.masksToBounds = YES;
//    self.distanceLabel.textColor = [UIColor colorWithWhite:1 alpha:0];
    if (!animationRunning) {
      animationRunning = TRUE;
      [NSTimer scheduledTimerWithTimeInterval:2 target:self
                                     selector:@selector(searchTimerPopped:)
                                     userInfo:nil
                                      repeats:TRUE];
    }

    self.compassImage.transform = CGAffineTransformMakeRotation((direction* M_PI / 180) + geoAngle);
  }
}
      
-(void) searchTimerPopped:(NSTimer *)timer {
  [UIView transitionWithView:self.distanceLabel duration:1 options:UIViewAnimationOptionCurveLinear animations:^{
    self.distanceLabel.layer.backgroundColor = customGreenColor.CGColor;
    self.distanceLabel.layer.cornerRadius = 3;
    self.distanceLabel.layer.masksToBounds = YES;
    self.distanceLabel.textColor = [UIColor whiteColor];
  } completion:^(BOOL finished){
    self.distanceLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
      self.distanceLabel.textColor = customGreenColor;
  }];
  
//  [UIView animateWithDuration:0.6
//                        delay:0.2
//                      options:(UIViewAnimationOptionCurveEaseIn)
//                   animations:^{
//  self.distanceLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
//                   } completion:^(BOOL finished) {
//                     if (finished) {
//                       [UIView animateWithDuration:1
////                                             delay:0
////                                           options:(UIViewAnimationOptionCurveEaseOut)
//                                        animations:^{
////                                          self.distanceLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
////                                          self.distanceLabel.textColor = customGreenColor;
//                                          self.distanceLabel.textColor = [UIColor colorWithWhite:1 alpha:0.3];
//                                        } completion:^(BOOL finished) {
//                                          
//                                        }];
//                     }
//                   }];
}

//- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
//  return YES;
//}

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