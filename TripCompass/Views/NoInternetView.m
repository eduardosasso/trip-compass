//
//  NoInternetView.m
//  TripCompass
//
//  Created by Eduardo Sasso on 2/16/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "NoInternetView.h"

@implementation NoInternetView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"NoInternetView" owner:self options:nil] firstObject];
    [self addSubview:view];
  }
  return self;
}

@end
