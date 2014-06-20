//
//  API.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/11/13.
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

#import "API.h"
#import <CoreLocation/CoreLocation.h>
#import "GogobotSignature.h"
#import "NSDictionary+QueryString.h"

#define BASE_URL @"http://api.gogobot.com/api/v3"
#define NEARBY_ENDPOINT @"/search/nearby_search.json"
#define REGIONS_ENDPOINT @"/search/regions.json"

const int RESULTS_PER_PAGE = 20;

@implementation API {
  double lat;
  double lng;
}

- (id)initWithLatitude:(double)latitude longitude:(double)longitude {
  self = [super init];

  lat = latitude;
  lng = longitude;
  
  return self;
}

- (void)makeRequestWithEndpoint:(NSString *)endpoint params:(NSDictionary *)params {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
  
  NSString *api = BASE_URL;
  api = [api stringByAppendingString:endpoint];
  
  NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params];
  [allParams setObject:[NSString stringWithFormat:@"%d", RESULTS_PER_PAGE] forKey:@"per_page"];
  
  api = [api stringByAppendingFormat:@"?%@", [allParams queryStringValue]];
  
  NSURL *url = [NSURL URLWithString:api];
  
  //NSLog(@"API: %@", url);
  
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

- (void)handleResults:(NSData *)data {
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
