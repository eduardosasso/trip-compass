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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  if (highlighted && !self.favoriteImage.highlighted) self.favoriteImage.highlighted = NO;
}

- (void)setSelected:(BOOL)highlighted animated:(BOOL)animated {
  [super setSelected:highlighted animated:animated];
  if (highlighted && !self.favoriteImage.highlighted) self.favoriteImage.highlighted = NO;
}

- (void)setup {
  defaultColor = [UIColor lightGrayColor];
  savedColor = nil;
  
  //setup tap events like a button
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFavoriteTap:)];
  [self.favoriteImage addGestureRecognizer:tapGestureRecognizer];
  tapGestureRecognizer.delegate = self;
  
  UIImage *img = [[self.favoriteImage image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.favoriteImage.image = img;
  
  BOOL highlight = [self.delegate shouldHighlightFavorite:self.tag];
     
  self.favoriteImage.tintColor = highlight ? savedColor : defaultColor;
  self.favoriteImage.highlighted = highlight;
}

- (void)toggleFavoriteTap:(UITapGestureRecognizer *)recognizer {
  UIColor *color;
  
  BOOL saved = [self.delegate didTapAddToFavorite:self.tag];
  
  color = saved ? savedColor : defaultColor;

  self.favoriteImage.tintColor = color;
  self.favoriteImage.highlighted = saved;
}

@end