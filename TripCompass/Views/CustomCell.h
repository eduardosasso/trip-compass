//
//  CustomCell.h
//  TripCompass
//
//  Created by Eduardo Sasso on 11/4/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface CustomCell : UITableViewCell <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;

- (void)setPlaceWithLocation:(Place *)selectedPlace location:(CLLocation *)location;

- (CGFloat)calculateHeight:(NSString *)text;

@end
