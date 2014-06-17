#import "AppDelegate.h"
#import "PlaceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "API.h"
#import "CustomCell.h"
#import "NoInternetView.h"
#import "Reachability.h"

@implementation PlaceViewController {
  NSString *placeType;
  
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  CLLocation *selectedLocation;

  API *api;
  NSMutableArray *results;
  NSArray *apiResults;
  
  NSString *city;
  
  NSTimer *searchTimer;
  
  NSInteger page;
  
  BOOL loading;
  BOOL isSearching;
  
  Reachability *internetConnection;
  NoInternetView *noInternetView;
  
  CustomCell *prototypeCell;
}

#pragma mark Controller Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self resetTableView];
  [self startTrackingLocation];
//  [self checkInternetConnection];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];
  
  self.tableView.rowHeight = 60;
  self.searchDisplayController.searchResultsTableView.rowHeight = 60;
  
  isSearching = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [self checkInternetConnection];
}

#pragma mark API

- (void)didReceiveAPIResults:(NSDictionary *)dictionary {
  [self.refreshControl endRefreshing];
  
  apiResults = [dictionary valueForKey:@"results"];
  
  if (results && !isSearching) {
    [results addObjectsFromArray:apiResults];
  } else {
    results = [(NSArray*)apiResults mutableCopy];
  }

  UITableView *tableView = self.tableView;
  if (isSearching) tableView = self.searchDisplayController.searchResultsTableView;

  [tableView reloadData];
  
  loading = false;
}

- (void)resetTableView {
  page = 1;
  apiResults = nil;
  results = nil;
}

- (void)requestUpdateTableViewData:(CLLocation *)location {
  //TODO check if location services enabled...
  //it hangs here if no location on simulator
  if (!location) return;
  
  loading = true;
  api = [[API alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
  [api setDelegate:self];
  
  NSArray *placeTypes = @[@"Attractions", @"Hotels", @"Restaurants"];
  long item = [placeTypes indexOfObject:placeType];
  switch (item) {
    case 0:
      [api requestAttractionsNearby:page];
      break;
    case 1:
      [api requestHotelsNearby:page];
      break;
    case 2:
      [api requestRestaurantsNearby:page];
      break;
    default:
      [api requestPlacesNearby:page];
      break;
  }
}

- (void)requestUpdateTableViewDataWithPagination {
  results.count == 0 ? page=1 : page++;
  [self requestUpdateTableViewData:selectedLocation];
}

#pragma mark Delegates

- (void)didSelectPlaceType:(NSString *)type {
  int centerPosition = 6;
  int topPosition = 0;

  placeType = type;

  if ([placeType isEqualToString:@"All"]) {
    self.verticalSpaceConstraint.constant = centerPosition;
    self.windowSubtitle.text = nil;
  } else {
    self.windowSubtitle.text = placeType;
    self.verticalSpaceConstraint.constant = topPosition;
  }

  [UIView animateWithDuration:0.5 animations:^{
    [self.navigationItem.titleView layoutIfNeeded];
  }];
  
  [self resetTableView];
  [self.tableView reloadData];
  [self requestUpdateTableViewData:selectedLocation];
}

- (void)didSelectLocation:(CLLocation *)location city:(NSString *)newCity {
  selectedLocation = location;
//  currentLocation = selectedLocation;
  
  //if nil assume it's on current location
  city = newCity;
  if (!city) [self findCity:selectedLocation];
  
  self.windowTitle.text = city;

  [self resetTableView];
  
  [self.tableView reloadData];
  
  [self requestUpdateTableViewData:selectedLocation];
}

#pragma mark UITableView

- (IBAction)pullToRefresh:(id)sender {
  currentLocation = nil;
  [self resetTableView];
  [self startTrackingLocation];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  BOOL noMoreResults = apiResults && [apiResults count] < RESULTS_PER_PAGE;
  
  if (noMoreResults || (isSearching && [apiResults count] > 0)) {
    return results.count;
  } else {
    //+1 for the loading cell
    return results.count + 1;
  }
}

- (void)configureCell:(CustomCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  Place *place = [Place convertFromDictionary:[results objectAtIndex:indexPath.row] withCity:city];

  cell.placeLabel.text = place.name;

  if (!placeType || [placeType isEqualToString:@"All"]) {
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@ %@", [place formattedDistanceTo:currentLocation.coordinate], @"‑", place.type];
  } else {
    cell.detailLabel.text = [place formattedDistanceTo:currentLocation.coordinate];
  }
  
  cell.tag = indexPath.row;
  
  if ([place saved]) {
    cell.placeLabel.textColor = customMagentaColor;
  } else {
    cell.placeLabel.textColor = nil;
  }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < results.count) {
    CustomCell *customCell = [self.tableView dequeueReusableCellWithIdentifier:@"customCell"];

    [self configureCell:customCell forRowAtIndexPath:indexPath];
    [customCell setDelegate:self];
    [customCell setup];
    
    return customCell;
  } else {
    //return the loading spinner cell
    UITableViewCell *loadingCell = [self.tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    [(UIActivityIndicatorView *)loadingCell.contentView.subviews.firstObject startAnimating];
    return loadingCell;
  }
}

- (CustomCell *)prototypeCell {
  if (!prototypeCell) {
    prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
  }
  return prototypeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < results.count) {
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    [self.prototypeCell layoutIfNeeded];
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
  } else {
    return tableView.rowHeight;
  }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return tableView.rowHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  //load more records if at the bottom of the page
  if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
    if (!loading && !isSearching) {
      [self requestUpdateTableViewDataWithPagination];
      //TODO this is calling the api if tries to scroll results
      //if ([cell.reuseIdentifier isEqualToString:@"loadingCell"] && tableView != self.searchDisplayController.searchResultsTableView) [self requestUpdateTableViewDataWithPagination];
    }
  }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  if ([cell isKindOfClass:CustomCell.class]) {
    [self performSegueWithIdentifier:@"CompassViewController" sender:self];
  } else {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/gogobot/id459590827?mt=8&ls=1"]];
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Search
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  isSearching = NO;
  
  [self resetTableView];
  [self.tableView reloadData];
  [self requestUpdateTableViewData:selectedLocation];
}

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

-(void)searchTimerPopped:(NSTimer *)timer {
  NSString *searchString = (NSString*)[timer userInfo];
  
  [api searchPlacesNearby:searchString];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  //reset table to clear regular results
  [self resetTableView];
  
  isSearching = YES;
}

#pragma mark Location Manager
- (void)startTrackingLocation {
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  locationManager.distanceFilter = 100;

  if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
   [locationManager startUpdatingLocation];
  } else {
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Location services disabled"
                                                  message:@"Trip Compass needs access to your location. Please turn on Location Services in your device settings."
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [self resetTableView];
    [self.tableView reloadData];
    [alert show];
  }
  [self.refreshControl endRefreshing];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  // The value is not older than 1 sec.
  if (!currentLocation || [manager.location.timestamp timeIntervalSinceNow] > -1.0) {
    currentLocation = (CLLocation *)[locations lastObject];
    selectedLocation = currentLocation;

    if (!isSearching) [self requestUpdateTableViewData:currentLocation];

    [self findCity:selectedLocation];
    
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];
  }
}

- (void)findCity:(CLLocation *)location {
  CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
  [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
    city = [[placemarks objectAtIndex:0] locality];
    self.windowTitle.text = city;
  }];
}

#pragma mark Internet Connection

- (void)checkInternetConnection {
  noInternetView = [[NoInternetView alloc] init];
  [self.navigationController.view addSubview:noInternetView];
  
  internetConnection = [Reachability reachabilityForInternetConnection];
  
  [self toggleInternetView:[internetConnection isReachable]];
  
  [internetConnection startNotifier];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(internetConnectionDidChange:)
                                               name:kReachabilityChangedNotification object:nil];
}

- (void)internetConnectionDidChange:(NSNotification *)notification {
  internetConnection = (Reachability *)[notification object];
  [self toggleInternetView:[internetConnection isReachable]];
}

- (void)toggleInternetView:(BOOL)connected {
  [noInternetView setHidden:connected];
  [self.tableView setHidden:!connected];

  if (!connected) [self.navigationController.view bringSubviewToFront:noInternetView];
  if (results.count == 0) [self startTrackingLocation];
}

#pragma mark Undefined

- (NSString *)googleAnalyticsScreenName {
  return NSStringFromClass([self class]);
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  UIViewController *destination = segue.destinationViewController;
  
  if([[segue identifier] isEqualToString:@"CompassViewController"]) {
    UINavigationController *dest = (UINavigationController *)segue.destinationViewController;
    
    CompassViewController *compassViewController = (CompassViewController *)dest.topViewController;
    destination = compassViewController;
  }
  
  if([[segue identifier] isEqualToString:@"PlaceTypeViewController"]) {
    PlaceTypeViewController *placeTypeViewController = (PlaceTypeViewController *)[segue.destinationViewController topViewController];
    //register this class as a delegate so it will receive events defined in the delegate class
    [placeTypeViewController setDelegate:self];
    
    //pass the current filter back so we can highlight the current selection
    placeTypeViewController.placeType = placeType;
  }
  
  if([[segue identifier] isEqualToString:@"LocationSearchViewController"]) {
    LocationSearchViewController *locationSearchViewController = (LocationSearchViewController *)[segue.destinationViewController topViewController];
    //register this class as a delegate so it will receive events defined in the delegate class
    [locationSearchViewController setDelegate:self];
  }

  if ([destination respondsToSelector:@selector(setPlace:)]) {
    NSIndexPath *path = [[self currentTableView] indexPathForSelectedRow];
    Place *selectedPlace = [Place convertFromDictionary:[results objectAtIndex:path.row] withCity:city];
    
    [destination performSelector:@selector(setPlace:)
                                          withObject:selectedPlace];
  }
}

- (UITableView *)currentTableView {
  return isSearching ? self.searchDisplayController.searchResultsTableView : self.tableView;
}

#pragma mark CustomCell Delegate

- (BOOL)didTapAddToFavorite:(NSInteger)row {
  BOOL status;
  UIColor *color = nil;
  CustomCell *cell;
  UITableView *currentTableView;
  
  Place *place = [Place convertFromDictionary:[results objectAtIndex:row] withCity:city];

  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
  
  currentTableView = self.tableView;
  
  if (isSearching) currentTableView = self.searchDisplayController.searchResultsTableView;
  
  cell = (CustomCell *)[currentTableView cellForRowAtIndexPath:indexPath];
  
  int badgeValue = [[[super.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue intValue];
  
  if ([place saved]) {
    [place destroy];
    status = FALSE;
    if (badgeValue > 0) --badgeValue;
  } else {
    [place save];
    color = customMagentaColor;
    ++badgeValue;
    status = TRUE;
  }
  
  if (badgeValue == 0) {
    [[super.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = nil;
  } else {
   [[super.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat: @"%d", badgeValue];
  }
  
  cell.placeLabel.textColor = color;
  return status;
}

- (BOOL)shouldHighlightFavorite:(NSInteger)row {
  Place *place = [Place convertFromDictionary:[results objectAtIndex:row] withCity:city];
  
  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
  CustomCell *cell = (CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
  
  if ([place saved]) {
    cell.placeLabel.textColor = customMagentaColor;
    return TRUE;
  } else {
//    cell.placeLabel.textColor = nil;
    return FALSE;
  }
}


@end