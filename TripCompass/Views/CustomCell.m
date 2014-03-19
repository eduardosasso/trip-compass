//
//  CustomCell.m
//  TripCompass
//
//  Created by Eduardo Sasso on 11/4/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell {
  Place *place;
  UIColor *defaultColor;
  UIColor *savedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)setPlaceWithLocation:(Place *)selectedPlace location:(CLLocation *)location {
  place = selectedPlace;
  
  [self setupImage];
  
  self.placeLabel.text = place.name;
  self.detailLabel.text = [place formattedDistanceTo:location.coordinate];
}

- (void)setupImage {
  defaultColor = [UIColor lightGrayColor];
  savedColor = nil;
  
  //setup tap events like a button
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFavoriteTap:)];
  [self.favoriteImage addGestureRecognizer:tapGestureRecognizer];
  tapGestureRecognizer.delegate = self;
  
  UIImage *img = [[self.favoriteImage image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.favoriteImage.image = img;
  self.favoriteImage.tintColor = [place saved] ? savedColor : defaultColor;
}

- (void)toggleFavoriteTap:(UITapGestureRecognizer *)recognizer {
  UIColor *color;
  
  if ([place saved]) {
    [place destroy];
    color = defaultColor;
  } else {
    [place save];
    color = savedColor;
  }
  
  [UIView animateWithDuration:0.2f animations:^{
    self.favoriteImage.tintColor = color;
  }];
}

@end