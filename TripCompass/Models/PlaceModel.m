//
//  PlaceModel.m
//  TripCompass
//
//  Created by Eduardo Sasso on 3/5/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "PlaceModel.h"

@implementation PlaceModel

@dynamic address;
@dynamic checkpoint;
@dynamic created;
@dynamic desc;
@dynamic lat;
@dynamic lng;
@dynamic name;
@dynamic key;
@dynamic city;
@dynamic country;
@dynamic state;

- (void)awakeFromInsert {
  [super awakeFromInsert];
  self.created = [NSDate date];
}

@end
