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

- (CGFloat)calculateHeight:(NSString *)text {
  return [text boundingRectWithSize:self.placeLabel.frame.size
                            options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:self.placeLabel.font}
                            context:nil].size.height;
  
  //+1 is the only way to get the height right, seems to be a bug from Apple
//  return height + 1;
  
//  self.frame= [self.text boundingRectWithSize:self.frame.size
//                                      options:NSStringDrawingUsesLineFragmentOrigin
//                                   attributes:@{NSFontAttributeName:self.font}
//                                      context:nil];
  
//  CGFloat questionTitleHeight = [questionTitle boundingRectWithSize: cellConstraintSize
//                                                            options: NSStringDrawingUsesLineFragmentOrigin
//                                                            context: NULL].size.height;
  
// [_nameCell.textLabel.text boundingRectWithSize:(CGSize) { 270, CGFLOAT_MAX } options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:_nameCell.textLabel.font } context:nil].size.height + 40;
  
//  if([[label text] respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
//    NSLog(@"iOS 7 Selector: boundingRectWithSize:options:attributes:context:");
//    size = [[label text]
//            boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
//            options:NSStringDrawingUsesLineFragmentOrigin
//            attributes:@{NSFontAttributeName:label.font} context:nil].size;
}

@end