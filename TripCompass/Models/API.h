//
//  API.h
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
