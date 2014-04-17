//
//  Place.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/12/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Place : NSObject

@property (nonatomic, copy) NSNumber *key;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lng;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) BOOL checkpoint;

- (void)save;

- (void)destroy;

- (BOOL)saved;

- (double)distanceTo:(CLLocationCoordinate2D)location;

- (NSString *)formattedDistanceTo:(CLLocationCoordinate2D)location;

- (CLLocationCoordinate2D)getCoordinate;

+ (Place *)convertFromDictionary:(NSDictionary *)dictionary withCity:(NSString *)city;

@end