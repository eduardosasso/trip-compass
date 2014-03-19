//
//  PlaceModel.m
//  TripCompass
//
//  Created by Eduardo Sasso on 3/19/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "PlaceModel.h"


@implementation PlaceModel

@dynamic address;
@dynamic checkpoint;
@dynamic city;
@dynamic country;
@dynamic created;
@dynamic desc;
@dynamic key;
@dynamic lat;
@dynamic lng;
@dynamic name;
@dynamic state;
@dynamic distance;

- (void)awakeFromInsert {
  [super awakeFromInsert];
  self.created = [NSDate date];
}

@end
