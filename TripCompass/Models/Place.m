//
//  Place.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/12/13.
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
  
  //distance is returned in meters by default
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
  place.type = [dictionary objectForKey:@"type"];
  
  return place;
}

@end
