//
//  API.h
//  TripCompass
//
//  Created by Eduardo Sasso on 12/11/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern const int RESULTS_PER_PAGE;

@protocol APIDelegate <NSObject>
- (void)didReceiveAPIResults:(NSDictionary *)dictionary;
@end

@interface API : NSObject

@property (nonatomic, weak) id<APIDelegate> delegate;

- (id)initWithLatitude:(double)latitude longitude:(double)longitude;

- (void)requestPlacesNearby:(NSInteger)page;

- (void)searchPlacesNearby:(NSString *)query;

- (void)requestRestaurantsNearby:(NSInteger)page;

- (void)requestAttractionsNearby:(NSInteger)page;

- (void)requestHotelsNearby:(NSInteger)page;

- (void)requestCitiesNearby;

- (void)searchCitiesNearby:(NSString *)query;

@end
