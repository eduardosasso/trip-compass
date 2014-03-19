//
//  Util.m
//  Pods
//
//  Created by Eduardo Sasso on 7/22/13.
//
//

#import "Util.h"

@implementation Util

#define METERS_TO_FEET  3.2808399
#define METERS_TO_MILES 0.000621371192
#define METERS_CUTOFF   500
#define FEET_CUTOFF     2000
#define FEET_IN_MILES   5280

#define RadiansToDegrees(radians)(radians * 180.0/M_PI)
#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)

+ (NSString *)stringWithDistance:(double)distance {
  BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"];
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
  [numberFormatter setMaximumFractionDigits:0];
  NSString *format;
  
  if (isMetric) {
    if (distance < METERS_CUTOFF) {
      [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
      format = @"%@ m";
    } else {
      format = @"%@ km";
      distance = distance / 1000;
      [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
      [numberFormatter setMaximumFractionDigits:1];
    }
  } else { // assume Imperial / U.S.
    distance = distance * METERS_TO_FEET;
    if (distance < FEET_CUTOFF) {
      [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
      format = @"%@ ft";
    } else {
      format = @"%@ mi";
      distance = distance / FEET_IN_MILES;
      [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
      [numberFormatter setMaximumFractionDigits:2];
    }
  }
  
  [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
  NSString *roundDistance = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:distance]];
  
  return [NSString stringWithFormat:format, roundDistance];
}

+(float) angleToRadians:(float) a {
  return ((a/180)*M_PI);
}

+(float) getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
  
  float fLat = [self angleToRadians:fromLoc.latitude];
  float fLng = [self angleToRadians:fromLoc.longitude];
  float tLat = [self angleToRadians:toLoc.latitude];
  float tLng = [self angleToRadians:toLoc.longitude];
  
  return atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng));
}

+(float)setLatLonForDistanceAndAngle:(CLLocationCoordinate2D)userlocation toCoordinate:(CLLocationCoordinate2D)toLoc {
  float lat1 = DegreesToRadians(userlocation.latitude);
  float lon1 = DegreesToRadians(userlocation.longitude);
  
  float lat2 = DegreesToRadians(toLoc.latitude);
  float lon2 = DegreesToRadians(toLoc.longitude);
  
  float dLon = lon2 - lon1;
  
  float y = sin(dLon) * cos(lat2);
  float x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
  float radiansBearing = atan2(y, x);
  if(radiansBearing < 0.0)
  {
    radiansBearing += 2*M_PI;
  }
  
  return radiansBearing;
}

@end
