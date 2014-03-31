#import "LocationSearchViewController.h"
#import "API.h"

@implementation LocationSearchViewController {
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  
  API *api;
  NSArray *results;
  NSTimer *searchTimer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self startTrackingLocation];
  
  self.navigationItem.rightBarButtonItem = self.closeButton;
  
  api = [[API alloc] initWithLatitude:0.0 longitude:0.0];
  [api setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
  [self.searchBar becomeFirstResponder];
}

#pragma mark API

-(void)didReceiveAPIResults:(NSDictionary *)dictionary {
  results = [dictionary valueForKey:@"results"];
  
  [self.refreshControl endRefreshing];
  [self.searchDisplayController.searchResultsTableView reloadData];
  [self.tableView reloadData];
}

#pragma mark Search Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  if (searchTimer) {
    [searchTimer invalidate];
    searchTimer = nil;
  }
  
  if ([searchString length] <= 2) return NO;
  
  searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
                                               selector:@selector(searchTimerPopped:)
                                               userInfo:searchString
                                                repeats:FALSE];
  return NO;
}

-(void) searchTimerPopped:(NSTimer *)timer {
  NSString *searchString = (NSString*)[timer userInfo];

  [api searchLocation:searchString];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self.tableView reloadData];
}

#pragma mark Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  
  cell = [self.tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
  NSDictionary *dictionary = [results objectAtIndex:indexPath.row];
  Place *place = [[Place alloc] init];
  
  place.name = [dictionary objectForKey:@"long_name"];
  place.lat = [NSNumber numberWithDouble:[[dictionary objectForKey:@"lat"] doubleValue]];
  place.lng = [NSNumber numberWithDouble:[[dictionary objectForKey:@"lng"] doubleValue]];

  cell.textLabel.text = place.name;
  cell.detailTextLabel.text = [place formattedDistanceTo:currentLocation.coordinate];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  //  NSIndexPath *indexPathx = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
  
  if ([cell.reuseIdentifier isEqual: @"DefaultCell"]) {
//    Place *place = [places objectAtIndex:(indexPath.row-1)];
    //    appDelegate.selectedLocation = place;
  }

  NSDictionary *city = [results objectAtIndex:indexPath.row];
  
  NSString *name = [city valueForKeyPath:@"name"];
  NSNumber *lat = [city valueForKeyPath:@"lat"];
  NSNumber *lng = [city valueForKeyPath:@"lng"];
  
  CLLocation *location = [[CLLocation alloc]initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];

  [self.delegate didSelectLocation:location city:name];
  
//  [[NSNotificationCenter defaultCenter] postNotificationName:@"newLocationSelected" object:self userInfo:location];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeButtonClick:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
//  self.closeButtonClicked = YES;
//  [self performSegueWithIdentifier:@"unwindToSearchController" sender:self];

//  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetTableView {
  results = nil;
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
  }
}


- (NSString *)googleAnalyticsScreenName {
  return @"Location Search";
}

@end
