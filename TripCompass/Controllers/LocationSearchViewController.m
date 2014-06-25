//
//  LocationSearchViewController.m
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

#import "LocationSearchViewController.h"
#import "API.h"
#import "CustomCell.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation LocationSearchViewController {
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  
  API *api;
  NSMutableArray *results;
  NSArray *apiResults;

  NSTimer *searchTimer;
  
  BOOL isSearching;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self startTrackingLocation];
  
  isSearching = NO;
  
  api = [[API alloc] initWithLatitude:0.0 longitude:0.0];
  [api setDelegate:self];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];
  self.searchDisplayController.searchResultsTableView.rowHeight = 60;
  self.tableView.rowHeight = 60;
}

#pragma mark API Delegate

- (void)didReceiveAPIResults:(NSDictionary *)dictionary {
  [self.refreshControl endRefreshing];

  apiResults = [dictionary valueForKey:@"results"];

  if (isSearching) {
    results = [(NSArray*)apiResults mutableCopy];
  } else {
    results = [(NSArray*)apiResults mutableCopy];
    [results insertObject:[NSNull null] atIndex:0];
  }
  
  UITableView *tableView = self.tableView;
  if (isSearching) tableView = self.searchDisplayController.searchResultsTableView;
  
  [tableView reloadData];
}

#pragma mark Search Delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self resetTableView];
  
  if (searchTimer) {
    [searchTimer invalidate];
    searchTimer = nil;
  }
  
  if ([searchString length] <= 2) return NO;

  searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
                                               selector:@selector(searchTimerPopped:)
                                               userInfo:searchString
                                                repeats:FALSE];
  return YES;
}

- (void)searchTimerPopped:(NSTimer *)timer {
  NSString *searchString = (NSString*)[timer userInfo];

  [api searchCitiesNearby:searchString];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  //reset table to clear regular results
  [self resetTableView];

  isSearching = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [api requestCitiesNearby];
  isSearching = NO;
}

#pragma mark Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  BOOL noMoreResults = apiResults && [apiResults count] == 0;
  
  if (noMoreResults || [apiResults count] > 0) {
    return results.count;
  } else {
    //+1 for the loading cell
    return results.count + 1;
  }
}

- (Place *)tableview:(UITableView *)tableView selectPlaceFromIndex:(NSIndexPath *)indexPath {
  NSDictionary *dictionary = [results objectAtIndex:indexPath.row];
  Place *place = [[Place alloc] init];
  
  if (isSearching) {
    place.name = [dictionary objectForKey:@"long_name"];
    place.lat = [NSNumber numberWithDouble:[[dictionary objectForKey:@"lat"] doubleValue]];
    place.lng = [NSNumber numberWithDouble:[[dictionary objectForKey:@"lng"] doubleValue]];
    place.city = [dictionary objectForKey:@"name"];
  } else {
    if (indexPath.row == 0) {
      place.name = @"Current Location";
      place.lat = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
      place.lng = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
      place.city = nil;
    } else {
      place = [Place convertFromDictionary:[results objectAtIndex:indexPath.row] withCity:nil];
      place.city = place.name;
    }
  }
  return place;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < results.count) {
    CustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"customCell"];

    Place *place = [self tableview:tableView selectPlaceFromIndex:indexPath];
    
    cell.placeLabel.text = place.name;
    cell.detailLabel.text = [place formattedDistanceTo:currentLocation.coordinate];
    [cell.favoriteImage setHidden:YES];
    
    if ([place.name isEqual:@"Current Location"]) {
      UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
      UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
      cell.placeLabel.font = [UIFont fontWithDescriptor:boldFontDescriptor size:0.f];
      cell.placeLabel.textColor = customMagentaColor;
      
      cell.detailLabel.text = @"You are here";
    } else {
      cell.placeLabel.font = nil;
      cell.placeLabel.textColor = nil;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
  } else {
    //return the loading spinner cell
    UITableViewCell *loadingCell = [self.tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    [(UIActivityIndicatorView *)loadingCell.contentView.subviews.firstObject startAnimating];
    return loadingCell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  if ([cell isKindOfClass:CustomCell.class]) {
    Place *place = [self tableview:tableView selectPlaceFromIndex:indexPath];
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:[place.lat doubleValue]
                                                     longitude:[place.lng doubleValue]];
    
    [self.delegate didSelectLocation:location city:place.city];
    
    [self dismissViewControllerAnimated:YES completion:nil];
  } else {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"gogobot_tap"
                                                           label:@"LocationSearchViewController"
                                                           value:nil] build]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/gogobot/id459590827?mt=8&ls=1"]];
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)closeButtonClick:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetTableView {
  apiResults = nil;
  results = nil;
}

- (IBAction)pullToRefresh:(id)sender {
  [api requestCitiesNearby];
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
  // The value is not older than 1 sec.
  if (!currentLocation || [manager.location.timestamp timeIntervalSinceNow] > -1.0) {
    currentLocation = (CLLocation *)[locations lastObject];
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];
    
    api = [[API alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    [api requestCitiesNearby];
    [api setDelegate:self];
  }
}

- (NSString *)googleAnalyticsScreenName {
  return NSStringFromClass([self class]);
}

@end
