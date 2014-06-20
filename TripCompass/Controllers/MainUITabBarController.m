//
//  MainUITabBarController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/2/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "MainUITabBarController.h"
#import "AppDelegate.h"

@interface MainUITabBarController ()
@end

@implementation MainUITabBarController {
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)transitionToCompassView {
  int controllerIndex = 1;
  
  UITabBarController *tabBarController = self.tabBarController;
  UIView * fromView = tabBarController.selectedViewController.view;
  
  UIView * toView = [[tabBarController.viewControllers objectAtIndex:controllerIndex] view];
  
  // Transition using a page curl.
  [UIView transitionFromView:fromView
                      toView:toView
                    duration:0.5
                     options:(UIViewAnimationOptionTransitionCrossDissolve)
                  completion:^(BOOL finished) {
                    if (finished) {
                      tabBarController.selectedIndex = controllerIndex;
                    }
                  }];
  
}

@end
