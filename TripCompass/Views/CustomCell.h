//
//  CustomCell.h
//  TripCompass
//
//  Created by Eduardo Sasso on 11/4/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@protocol CustomCellDelegate <NSObject>
- (BOOL)didTapAddToFavorite:(NSInteger)row;
- (BOOL)shouldHighlightFavorite:(NSInteger)row;
@end

@interface CustomCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (assign, nonatomic) id<CustomCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;
- (void)setup;

//- (void)setPlaceWithLocation:(Place *)selectedPlace location:(CLLocation *)location;
@end
