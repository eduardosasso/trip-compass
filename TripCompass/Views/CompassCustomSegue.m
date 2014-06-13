//
//  CompassCustomSegue.m
//  TripCompass
//
//  Created by Eduardo Sasso on 6/9/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "CompassCustomSegue.h"
#import "CompassViewController.h"

@implementation CompassCustomSegue

- (void)perform {
  CATransition* transition = [CATransition animation];
  
  transition.duration = 0.2;
  transition.type = kCATransitionFade;
  transition.subtype = kCATransitionFromBottom;
  
  [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
  
  CompassViewController *viewController = [self destinationViewController];
//  viewController.hidesBottomBarWhenPushed = YES;
  
  [[self.sourceViewController navigationController] pushViewController:viewController animated:NO];
}

@end
