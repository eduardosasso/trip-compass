//
//  BookmarkItemViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
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

#import "BookmarkItemViewController.h"
#import "BookmarkItemCell.h"
#import "PlaceDataManager.h"

@implementation BookmarkItemViewController {
  NSMutableArray *places;

  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  
  BookmarkItemCell *prototypeCell;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"BookmarkItemCell" bundle:nil] forCellReuseIdentifier:@"bookmarkItemCell"];
  self.tableView.rowHeight = 60;
  
  [self.navigationController.navigationBar setBackIndicatorImage:
   [UIImage imageNamed:@"icon_navbar_back"]];
  [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:
   [UIImage imageNamed:@"icon_navbar_back"]];
}

- (void)viewWillAppear:(BOOL)animated {
  [self startTrackingLocation];
  
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.title = self.city;
}

#pragma mark Location Manager

- (void)startTrackingLocation {
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  locationManager.distanceFilter = 100;
  if([CLLocationManager locationServicesEnabled]) [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  currentLocation = (CLLocation *)[locations lastObject];
  
  [self findPlacesByCitySortedByDistance];
  
  [manager stopUpdatingLocation];
  [manager setDelegate:nil];
}

- (void)findPlacesByCitySortedByDistance {
  places = [NSMutableArray arrayWithArray:[PlaceDataManager findPlacesByCity:self.city]];
  
  for (PlaceModel *place in places) {
    CLLocationDegrees lat = [place.lat doubleValue];
    CLLocationDegrees lng = [place.lng doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    CLLocationDistance distance = [location distanceFromLocation:currentLocation];
    place.distance = [NSNumber numberWithDouble:distance];
  }

  NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
  [places sortUsingDescriptors:@[sort]];
  
  [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return places.count;
}

- (void)configureCell:(BookmarkItemCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  PlaceModel *placeModel = [places objectAtIndex:indexPath.row];
  
  Place *place = [[Place alloc] init];
  place.name = placeModel.name;
  place.address = placeModel.address;
  place.lat = placeModel.lat;
  place.lng = placeModel.lng;
  place.type = placeModel.type;
  
  cell.placeLabel.text = place.name;
  cell.detailLabel.text = [place formattedDistanceTo:currentLocation.coordinate];
  if (place.type) {
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@ %@", [place formattedDistanceTo:currentLocation.coordinate], @"‑", place.type];
  }
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BookmarkItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"bookmarkItemCell"];
  [self configureCell:cell forRowAtIndexPath:indexPath];
  
  return cell;
}

- (BookmarkItemCell *)prototypeCell {
  if (!prototypeCell) {
    prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"bookmarkItemCell"];
  }
  return prototypeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
  [self.prototypeCell layoutIfNeeded];
  CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
  return size.height+1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  PlaceModel *place = [places objectAtIndex:indexPath.row];
  
  [PlaceDataManager destroy:place.key];
  [places removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  
  if ([places count] == 0) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"CompassViewController" sender:self];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];

  PlaceModel *placeModel = [places objectAtIndex:path.row];
  Place *place = [[Place alloc] init];
  place.name = placeModel.name;
  place.address = placeModel.address;
  place.lat = placeModel.lat;
  place.lng = placeModel.lng;
  
  UINavigationController *navigation = (UINavigationController *)segue.destinationViewController;
  
  [navigation.topViewController performSelector:@selector(setPlace:)
                                     withObject:place];
}

-(NSString *)googleAnalyticsScreenName {
  return NSStringFromClass([self class]);
}

@end
