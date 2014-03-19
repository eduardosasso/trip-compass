//
//  PlaceModel.h
//  TripCompass
//
//  Created by Eduardo Sasso on 3/19/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlaceModel : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, assign) BOOL checkpoint;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * key;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * distance;

@end
