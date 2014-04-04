#import "LocationSearchViewController.h"
#import "API.h"

@implementation LocationSearchViewController {
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  
  API *api;
  NSMutableArray *results;
  NSTimer *searchTimer;
  
  BOOL isSearching;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self startTrackingLocation];
  
  self.navigationItem.rightBarButtonItem = self.closeButton;
  
  isSearching = NO;
  
  api = [[API alloc] initWithLatitude:0.0 longitude:0.0];
  [api setDelegate:self];
}

#pragma mark API Delegate

-(void)didReceiveAPIResults:(NSDictionary *)dictionary {
  results = [(NSArray*)[dictionary valueForKey:@"results"] mutableCopy];
  
  [self.refreshControl endRefreshing];

  if (isSearching) {
    [self.searchDisplayController.searchResultsTableView reloadData];
  } else {
    [results insertObject:[NSNull null] atIndex:0];
    [self.tableView reloadData];
  }

}

#pragma mark Search Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  if (searchTimer) {
    [searchTimer invalidate];
    searchTimer = nil;
  }
  
  if ([searchString length] <= 2) return YES;

  searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
                                               selector:@selector(searchTimerPopped:)
                                               userInfo:searchString
                                                repeats:FALSE];
  return YES;
}

-(void) searchTimerPopped:(NSTimer *)timer {
  NSString *searchString = (NSString*)[timer userInfo];

  [api searchCitiesNearby:searchString];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  //reset table to clear regular results
  [self resetTableView];

  isSearching = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  isSearching = NO;
}

#pragma mark Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [results count];
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
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];

  Place *place = [self tableview:tableView selectPlaceFromIndex:indexPath];
  
  cell.textLabel.text = place.name;
  cell.detailTextLabel.text = [place formattedDistanceTo:currentLocation.coordinate];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Place *place = [self tableview:tableView selectPlaceFromIndex:indexPath];
  
  CLLocation *location = [[CLLocation alloc]initWithLatitude:[place.lat doubleValue]
                                                   longitude:[place.lng doubleValue]];

  [self.delegate didSelectLocation:location city:place.city];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeButtonClick:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetTableView {
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
