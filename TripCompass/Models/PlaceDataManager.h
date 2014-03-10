//
//  DataManager.h
//  TripCompass
//
//  Created by Eduardo Sasso on 3/7/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceModel.h"
#import "Place.h"

@interface PlaceDataManager : NSObject

+ (BOOL)create:(Place *)place;

+ (void)destroy:(NSNumber *)id;

+ (void)destroyByCity:(NSString *)city;

+ (PlaceModel *)findById:(NSNumber *)id;

+ (NSArray *)findCities;

+ (NSArray *)findPlacesByCity:(NSString *)city;

//+ (NSArray *)findByCity:(NSString *)city;

@end
