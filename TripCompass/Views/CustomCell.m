//
//  CustomCell.m
//  TripCompass
//
//  Created by Eduardo Sasso on 11/4/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//  Copyright (c) 2014 Eduardo Sasso
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "CustomCell.h"

@implementation CustomCell {
  Place *place;
  UIColor *defaultColor;
  UIColor *savedColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  if (highlighted && self.favoriteImage.tintColor == defaultColor) {
    self.favoriteImage.highlighted = NO;
  }
}

- (void)setSelected:(BOOL)highlighted animated:(BOOL)animated {
  [super setSelected:highlighted animated:animated];
  if (highlighted && self.favoriteImage.tintColor == defaultColor) {
   self.favoriteImage.highlighted = NO; 
  }
}

- (void)setup {
  defaultColor = [UIColor lightGrayColor];
  savedColor = nil;
  
  self.selectionStyle = UITableViewCellSelectionStyleDefault;
  
  //setup tap events like a button
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFavoriteTap)];
  [self.favoriteImage addGestureRecognizer:tapGestureRecognizer];
  tapGestureRecognizer.delegate = self;
  
  UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:nil];
  [self.favoriteImage addGestureRecognizer:longPressGestureRecognizer];
  longPressGestureRecognizer.delegate = self;
  longPressGestureRecognizer.cancelsTouchesInView = NO;
  
  UIImage *img = [[self.favoriteImage image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.favoriteImage.image = img;
  
  BOOL highlight = [self.delegate shouldHighlightFavorite:self.tag];
     
  self.favoriteImage.tintColor = highlight ? savedColor : defaultColor;
  self.favoriteImage.highlighted = highlight;
}

- (void)toggleFavoriteTap {
  UIColor *color;
  
  BOOL saved = [self.delegate didTapAddToFavorite:self.tag];
  
  color = saved ? savedColor : defaultColor;

  self.favoriteImage.tintColor = color;
  self.favoriteImage.highlighted = saved;
}

@end
