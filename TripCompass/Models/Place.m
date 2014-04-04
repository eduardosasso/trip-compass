//
//  Place.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/12/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//
#import "PlaceDataManager.h"
#import "Place.h"
#import "Util.h"

@implementation Place

- (void)save {
  [PlaceDataManager create:self];
}

- (void)destroy {
  [PlaceDataManager destroy:self.key];
}

- (BOOL)saved {
  return [PlaceDataManager findById:self.key] != nil;
}

- (double)distanceTo:(CLLocationCoordinate2D)location {
  CLLocation *current = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
  CLLocation *destination = [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue]];
  
  //the distance is returned in meters by default
  return [current distanceFromLocation:destination];
}

- (NSString *)formattedDistanceTo:(CLLocationCoordinate2D)location {
  return [Util stringWithDistance: [self distanceTo:location]];
}

- (CLLocationCoordinate2D)getCoordinate {
  return CLLocationCoordinate2DMake([self.lat doubleValue], [self.lng doubleValue]);
}

+ (Place *)convertFromDictionary:(NSDictionary *)dictionary withCity:(NSString *)city {
  id place_lat = [dictionary valueForKeyPath:@"address.lat"];
  id place_lng = [dictionary valueForKeyPath:@"address.lng"];
  id key = [dictionary valueForKeyPath:@"id"];
  
  Place *place = [[Place alloc] init];
  place.key =  [[[NSNumberFormatter alloc] init] numberFromString:key];
  place.name = [dictionary objectForKey:@"name"];
  place.address = [[dictionary valueForKeyPath:@"address.address"]
                   isKindOfClass:[NSNull class]] ? nil :[dictionary valueForKeyPath:@"address.address"];
  place.lat = [NSNumber numberWithDouble:[place_lat doubleValue]];
  place.lng = [NSNumber numberWithDouble:[place_lng doubleValue]];
  place.city = city;
  
  return place;
}

@end