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
  
  NSMutableArray *results;

  API *api;
  NSArray *apiResults;
  
//  CLPlacemark *placemark;
  NSString *city;
  
  NSInteger page;
  BOOL loading;
  Reachability *internetConnection;
  NoInternetView *noInternetView;
  
  CustomCell *prototypeCell;
}

#pragma mark Controller Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self resetTableView];
  [self startTrackingLocation];
  [self checkInternetConnection];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];
  //hide search bar under the navigation bar
//  self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
  
  self.tableView.rowHeight = 60;
  
//  self.navigationItem.title = @"Current Location";
  self.windowTitle.text = @"Current Location";
}

#pragma mark API

- (void)didReceiveAPIResults:(NSDictionary *)dictionary {
  apiResults = [dictionary valueForKey:@"results"];
  
  [self.refreshControl endRefreshing];
  [self.tableView reloadData];
  
  loading = false;
  
  //hide the search bar when reloading
//  if (page ==1) {
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//  }
}

- (void)resetTableView {
  page = 1;
  results = [[NSMutableArray alloc] initWithCapacity:0];
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
  apiResults = [[NSArray alloc] init];
  
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
  [results addObjectsFromArray:apiResults];
  
  BOOL noMoreResults = page > 1 && apiResults.count == 0;
  BOOL noMoreSearchResults = tableView == self.searchDisplayController.searchResultsTableView && results.count > 0;

  if (noMoreResults || noMoreSearchResults) return results.count;
  
  //+1 for the loading cell
  return results.count + 1;
}

- (void)configureCell:(CustomCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  Place *place = [Place convertFromDictionary:[results objectAtIndex:indexPath.row] withCity:city];

  cell.placeLabel.text = place.name;
  cell.detailLabel.text = [place formattedDistanceTo:currentLocation.coordinate];
  cell.tag = indexPath.row;
  
  if ([place saved]) {
    cell.placeLabel.textColor = customMagentaColor;
  } else {
    cell.placeLabel.textColor = nil;
  }

//  cell.delegate = self;
  
//  [cell setPlaceWithLocation:place location:currentLocation];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    [(UIActivityIndicatorView *)cell.contentView.subviews.lastObject startAnimating];
    return cell;
  }
}

- (CustomCell *)prototypeCell {
  if (!prototypeCell) {
    prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
  }
  return prototypeCell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  if (indexPath.row < results.count) {
//    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
//    [self.prototypeCell layoutIfNeeded];
//    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
//    return size.height+1;
//  } else {
//    return self.tableView.rowHeight;
//  }
//}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  return UITableViewAutomaticDimension;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  //load more records if at the bottom of the page
  if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
    if (!loading) {
      [self requestUpdateTableViewDataWithPagination];
      //TODO this is calling the api if tries to scroll results
      //if ([cell.reuseIdentifier isEqualToString:@"loadingCell"] && tableView != self.searchDisplayController.searchResultsTableView) [self requestUpdateTableViewDataWithPagination];
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  [self performSegueWithIdentifier:@"CompassViewController" sender:self];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return  UITableViewCellEditingStyleInsert;
}

#pragma mark Search
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self resetTableView];
  [self requestUpdateTableViewData:selectedLocation];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [api searchPlacesNearby:searchString];
  [self resetTableView];
  return YES;
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
    selectedLocation = currentLocation;

    [self requestUpdateTableViewData:currentLocation];

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
  [self.view addSubview:noInternetView];
  
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
  [noInternetView setFrame: self.tableView.bounds];
  self.tableView.scrollEnabled = connected;

  if (connected) {
    if (results.count == 0) [locationManager startUpdatingLocation];
    [self.view sendSubviewToBack:noInternetView];
  } else {
    [self.view bringSubviewToFront:noInternetView];
  }
  
}

#pragma mark Undefined

- (NSString *)googleAnalyticsScreenName {
  return @"PlaceViewController";
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([[segue identifier] isEqualToString:@"PlaceTypeViewController"]) {
    PlaceTypeViewController * placeTypeViewController = (PlaceTypeViewController *)[segue.destinationViewController topViewController];
    //register this class as a delegate so it will receive events defined in the delegate class
    [placeTypeViewController setDelegate:self];
    
    //pass the current filter back so we can highlight the current selection
    placeTypeViewController.placeType = placeType;
  }
  
  if([[segue identifier] isEqualToString:@"LocationSearchViewController"]) {
    LocationSearchViewController * locationSearchViewController = (LocationSearchViewController *)[segue.destinationViewController topViewController];
    //register this class as a delegate so it will receive events defined in the delegate class
    [locationSearchViewController setDelegate:self];
  }

  if ([segue.destinationViewController respondsToSelector:@selector(setPlace:)]) {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    Place *selectedPlace = [Place convertFromDictionary:[results objectAtIndex:path.row] withCity:city];
    
    [segue.destinationViewController performSelector:@selector(setPlace:)
                                          withObject:selectedPlace];
  }
}

#pragma mark CustomCell Delegate

- (BOOL)didTapAddToFavorite:(NSInteger)row {
  BOOL status;
  UIColor *color = nil;
  
  Place *place = [Place convertFromDictionary:[results objectAtIndex:row] withCity:city];

  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
  CustomCell *cell = (CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
  
  if ([place saved]) {
    [place destroy];
    status = FALSE;
  } else {
    [place save];
    color = customMagentaColor;
    [[super.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = @"1";
    status = TRUE;
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
    cell.placeLabel.textColor = nil;
    return FALSE;
  }
}


@end