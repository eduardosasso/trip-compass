//
//  MainViewController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "GAITrackedViewController.h"

@interface CompassViewController : GAITrackedViewController

@property (nonatomic, retain) CLLocation *currentLocation;
//@property (weak, nonatomic) IBOutlet UIImageView *needleImage;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *compassImage;
- (IBAction)checkpointAction:(id)sender;

@end
