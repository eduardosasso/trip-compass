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

-(void)requestPlacesNearby:(NSInteger)page;

-(void)searchPlacesNearby:(NSString *)query;

-(void)requestRestaurantsNearby:(NSInteger)page;

-(void)requestAttractionsNearby:(NSInteger)page;

-(void)requestHotelsNearby:(NSInteger)page;

@end
