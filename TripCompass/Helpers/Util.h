//
//  Util.h
//  Pods
//
//  Created by Eduardo Sasso on 7/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Util : NSObject

+ (NSString *)stringWithDistance:(double)distance;
+ (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc;
+ (float)setLatLonForDistanceAndAngle:(CLLocationCoordinate2D)userlocation toCoordinate:(CLLocationCoordinate2D)toLoc;
+ (NSString *)getHeadingDirectionName:(CLHeading*)newHeading;
@end
