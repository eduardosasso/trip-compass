//
//  NoFavoritesView.m
//  TripCompass
//
//  Created by Eduardo Sasso on 4/28/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil] firstObject];
    [self addSubview:view];
//    [self addSubview:self.tipLabel];
  }
  return self;
}

@end
