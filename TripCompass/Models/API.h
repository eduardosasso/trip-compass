//
//  API.h
//  TripCompass
//
//  Created by Eduardo Sasso on 12/11/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface API : NSObject

-(id)initWithLatitude:(double)latitude longitude:(double)longitude;

-(void)getPlacesNearby;
-(void)getPlacesNearbyPage:(NSInteger)page;

-(void)searchPlacesNearby:(NSString *)query;

-(void) getRestaurantsNearby;

-(void) getAttractionsNearby;

-(void) getHotelsNearby;

@end
