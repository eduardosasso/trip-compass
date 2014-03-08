//
//  DataManager.m
//  TripCompass
//
//  Created by Eduardo Sasso on 3/7/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "PlaceDataManager.h"
#import "AppDelegate.h"

@implementation PlaceDataManager

+ (BOOL)create:(Place *)place {
  NSError *error;
  
  PlaceModel *placeModel = [NSEntityDescription insertNewObjectForEntityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  placeModel.key = place.key;
  
  placeModel.name = place.name;
  placeModel.address = [place.address isKindOfClass:[NSNull class]] ? nil :place.address;
  placeModel.lat = place.lat;
  placeModel.lng = place.lng;
  //TODO see if this will be available when saving a checkpoint offline
  placeModel.country = place.country;
  placeModel.state = place.state;
  placeModel.city = place.city;
  
  placeModel.checkpoint = false;
  
  if ([self.managedObjectContext save:&error]) {
    return YES;
  } else {
    //TODO do something with the error
    return NO;
  }
}

+ (void)destroy:(NSNumber *)id {
  PlaceModel *place = [self findById:id];
  [self.managedObjectContext deleteObject:place];
  [self.managedObjectContext save:nil];
}

+ (PlaceModel *)findById:(NSNumber *)id {
  NSError *error;
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
    
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", id]];
  
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  //TODO where to send?
  //if (error)
  return (PlaceModel *)[results firstObject];
}

+(NSArray *)findPlacesByCity:(NSString *)city {
  
}


+(NSManagedObjectContext *) managedObjectContext {
  return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
