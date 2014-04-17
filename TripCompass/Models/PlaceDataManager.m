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
  
  placeModel.checkpoint = place.checkpoint;
  
  if ([self.managedObjectContext save:&error]) {
    return YES;
  } else {
    NSLog(error);
    //TODO do something with the error
    return NO;
  }
}

//TODO change to destroyById
+ (void)destroy:(NSNumber *)id {
  PlaceModel *place = [self findById:id];
  [self.managedObjectContext deleteObject:place];
  [self.managedObjectContext save:nil];
}

+ (void)destroyByCity:(NSString *)city {
  NSArray *places = [self findPlacesByCity:city];
  
  for (NSManagedObject *place in places) {
    [self.managedObjectContext deleteObject:place];
  }
  
  [self.managedObjectContext save:nil];
}

//TODO refactor this to use basic find
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

+ (NSArray *)findCities {
  NSError *error;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  
  NSPropertyDescription *propDesc = [[entity propertiesByName] objectForKey:@"city"];
  NSExpression *emailExpr = [NSExpression expressionForKeyPath:@"city"];
  
  NSExpression *countExpr = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:emailExpr]];
  
  NSExpressionDescription *exprDesc = [[NSExpressionDescription alloc] init];
  [exprDesc setExpression:countExpr];
  [exprDesc setExpressionResultType:NSInteger64AttributeType];
  [exprDesc setName:@"count"];
  
  NSFetchRequest *fr = [[NSFetchRequest alloc] init];
  [fr setEntity:entity];
  
  [fr setPropertiesToGroupBy:[NSArray arrayWithObject:propDesc]];
  fr.sortDescriptors= @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
  
  [fr setPropertiesToFetch:[NSArray arrayWithObjects:propDesc, exprDesc, nil]];
  [fr setResultType:NSDictionaryResultType];
  
  return [self.managedObjectContext executeFetchRequest:fr error:&error];
}

+ (NSArray *)findPlacesByCity:(NSString *)city {
  return [self find:@"city" value:city];
}

+ (NSArray *)find:(NSString *)field value:(id)value {
  NSError *error;
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", field, value]];
  
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  return results;
}

+ (NSManagedObjectContext *)managedObjectContext {
  return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

@end
