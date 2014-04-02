//
//  API.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/11/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "API.h"
#import <CoreLocation/CoreLocation.h>
#import "GogobotSignature.h"
#import "NSDictionary+QueryString.h"

#define BASE_URL @"http://api.gogobot.com/api/v3"
#define NEARBY_ENDPOINT @"/search/nearby_search.json"
#define REGIONS_ENDPOINT @"/search/regions.json"

@implementation API {
  double lat;
  double lng;
}

//TODO define type constants for POI's

-(id)initWithLatitude:(double)latitude longitude:(double)longitude {
  self = [super init];

  lat = latitude;
  lng = longitude;
  
  return self;
}

-(void)makeRequestWithEndpoint:(NSString *)endpoint params:(NSDictionary *)params {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
  
  NSString *api = BASE_URL;
  api = [api stringByAppendingString:endpoint];
  api = [api stringByAppendingFormat:@"?%@", [params queryStringValue]];
  
  NSURL *url = [NSURL URLWithString:api];
  
  NSLog(@"API: %@", url);
  
  NSURLRequest *request = [GogobotSignature requestWithSignature:[NSURLRequest requestWithURL:url]];
  
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                                              
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                              if (httpResponse.statusCode == 200) {
                                                [self handleResults:data];
                                              } else {
                                                //TODO verify if need this else statement.
                                                //NSString *error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                //TODO force error to see if its capture on newrelic or crashlitcs
                                                //NSLog(@"Received HTTP %d: %@", httpResponse.statusCode, error);
                                              }
                                            });
                                          }];
  [task resume];
}

-(void)handleResults:(NSData *)data {
  NSError *jsonError;
  NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
  
  if (response) {
    [self.delegate didReceiveAPIResults:response];
  } else {
    //TODO this error should go somewhere
    NSLog(@"Error, %@", jsonError);
  }
}
- (void)searchPlacesNearby:(NSString *)query {
  NSDictionary *params = @{
                           @"lat" : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng" : [[NSNumber numberWithDouble: lng] stringValue],
                           @"query" : query
                          };
  
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

- (void)requestPlacesNearby:(NSInteger)page {
  NSDictionary *params = @{
                           @"lat"  : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng"  : [[NSNumber numberWithDouble: lng] stringValue],
                           @"page" : [[NSNumber numberWithLong: page] stringValue]
                           };
  
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

- (void)requestPlacesNearbyByType:(NSInteger)page type:(NSString *)type {
  NSDictionary *params = @{
                           @"lat"  : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng"  : [[NSNumber numberWithDouble: lng] stringValue],
                           @"page" : [[NSNumber numberWithLong: page] stringValue],
                           @"type" : type
                           };
  
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

- (void)requestRestaurantsNearby:(NSInteger)page {
  [self requestPlacesNearbyByType:page type:@"Restaurant"];
}

- (void)requestAttractionsNearby:(NSInteger)page {
  [self requestPlacesNearbyByType:page type:@"Attraction"];
}

- (void)requestHotelsNearby:(NSInteger)page {
  [self requestPlacesNearbyByType:page type:@"Hotel"];
}

- (void)requestCitiesNearby {
  [self requestPlacesNearbyByType:1 type:@"City"];
}

- (void)searchCitiesNearby:(NSString *)query {
  NSDictionary *params = @{
                           @"lat"  : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng"  : [[NSNumber numberWithDouble: lng] stringValue],
                           @"term" : query,
                           @"type" : @"City"
                           };
  
  [self makeRequestWithEndpoint:REGIONS_ENDPOINT params:params];
}

@end
