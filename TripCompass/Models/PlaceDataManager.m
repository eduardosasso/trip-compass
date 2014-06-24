//
//  DataManager.m
//  TripCompass
//
//  Created by Eduardo Sasso on 3/7/14.
//  Copyright (c) 2014 Eduardo Sasso
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "PlaceDataManager.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation PlaceDataManager

+ (BOOL)create:(Place *)place {
  PlaceModel *placeModel = [NSEntityDescription insertNewObjectForEntityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  placeModel.key = place.key;
  
  placeModel.name = place.name;
  placeModel.address = [place.address isKindOfClass:[NSNull class]] ? nil :place.address;
  placeModel.lat = place.lat;
  placeModel.lng = place.lng;
  placeModel.country = place.country;
  placeModel.state = place.state;
  placeModel.city = place.city;
  placeModel.type = place.type;
  
  placeModel.checkpoint = place.checkpoint;
  
  return [self.managedObjectContext save:nil];
}

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

+ (PlaceModel *)findById:(NSNumber *)id {
  NSError *error;
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
    
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", id]];
  
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  if (error) {
    NSString *message = [NSString stringWithFormat:@"Core Data error %@  %@", error, error.description];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createExceptionWithDescription:message
                                                                                            withFatal:[NSNumber numberWithBool:NO]] build]];
  }
  
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
