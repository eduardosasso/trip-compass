//
//  NoFavoritesView.m
//  TripCompass
//
//  Created by Eduardo Sasso on 4/28/14.
//  Copyright (c) 2014 Context Software. All rights reserved.
//

#import "NoFavoritesView.h"

@implementation NoFavoritesView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"NoFavoritesView" owner:self options:nil] firstObject];
      [self addSubview:view];
    }
    return self;
}

@end
