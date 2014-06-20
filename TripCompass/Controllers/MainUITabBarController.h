//
//  MainUITabBarController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 12/2/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface MainUITabBarController : UITabBarController <UITabBarControllerDelegate>

@property (strong, nonatomic) Place *place;

- (void)transitionToCompassView;

@end
