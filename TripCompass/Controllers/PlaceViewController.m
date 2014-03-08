#import "PlaceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "AppDelegate.h"
#import "API.h"
#import "CustomCell.h"
#import "NoInternetView.h"
#import "Reachability.h"

@interface PlaceViewController ()
@end

@implementation PlaceViewController {
  AppDelegate *appDelegate;
  
  NSString *placeType;
  
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  
  NSMutableArray *results;
  NSMutableArray *searchResults;

  API *api;
  NSArray *apiResults;
  
  CLPlacemark *placemark;
  
  NSInteger page;
  BOOL loading;
  Reachability *internetConnection;
  NoInternetView *noInternetView;
}

#pragma mark Controller Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self resetTableView];
  [self startTrackingLocation];
  [self checkInternetConnection];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];

  //todo get the initial size dynamically from the constraints
  //self.tableView.estimatedRowHeight = self.tabBarController.topLayoutGuide.length;
  
  //hide search bar under the navigation bar
  self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiResultsNotificationReceived:) name:@"apiResultsNotification" object:nil];
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//  self.managedObjectContext = [appDelegate managedObjectContext];
  
//  self.tabBarController.delegate = self;
//  defaultTableHeaderView = [self.tableView tableHeaderView];
  
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
}

#pragma mark API
- (void)apiResultsNotificationReceived:(NSNotification *)notification {
  apiResults = [[notification userInfo] valueForKey:@"results"];
  
  [self.refreshControl endRefreshing];
  [self.tableView reloadData];
  
  loading = false;
  
  //hide the search bar when reloading
  if (page ==1) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
  }
}

- (void)resetTableView{
  page = 1;
  results = [[NSMutableArray alloc] initWithCapacity:0];

//  [self.tableView reloadData];
  
}

- (void)requestUpdateTableViewData{
  //TODO check if location services enabled...
  //it hangs here if no location on simulator
  if (!currentLocation) return;
  
  loading = true;
  api = [[API alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
  
  NSArray *placeTypes = @[@"Attractions", @"Hotels", @"Restaurants"];
  int item = [placeTypes indexOfObject:placeType];
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
  [self requestUpdateTableViewData];
}

#pragma mark Delegates

- (void)didSelectPlaceType:(NSString *)type {
  placeType = type;
  [self resetTableView];
  [self requestUpdateTableViewData];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < results.count) {
    CustomCell *customCell = [self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
    
    Place *place = [Place convertFromDictionary:[results objectAtIndex:indexPath.row] withPlacemark:placemark];
    [customCell setPlaceWithLocation:place location:currentLocation];
    
    return customCell;
  } else {
    //return the loading spinner cell
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    [(UIActivityIndicatorView *)cell.contentView.subviews.lastObject startAnimating];
    return cell;
  }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  if (indexPath.row < results.count) {
//    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
//    Place *place = [self getPlace:indexPath.row];
//    
//    return [cell calculateHeight:place.name];
//  } else {
//    //TODO find a better way to return the default size
//    return self.tabBarController.topLayoutGuide.length;
//  }
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
  [self requestUpdateTableViewData];
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
    [self updateViewWithLocation:currentLocation];
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];
  }
}

- (void)updateViewWithLocation:(CLLocation *)location {
  CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
  [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
    [self requestUpdateTableViewData];
    
    //change the title to match the city name
    placemark = [placemarks objectAtIndex:0];
    self.navigationItem.title = placemark.locality;;
  }];
}

#pragma mark Internet Connection
- (void)checkInternetConnection {
  noInternetView = [[NoInternetView alloc] init];
  [self.view addSubview:noInternetView];
  
  internetConnection = [Reachability reachabilityForInternetConnection];
  
  [self toggleInternetView:[internetConnection isReachable]];
  
  [internetConnection startNotifier];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionDidChange:) name:kReachabilityChangedNotification object:nil];
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
  if([[segue identifier] isEqualToString:@"placeType"]) {
    PlaceTypeViewController * placeTypeViewController = (PlaceTypeViewController *)[segue.destinationViewController topViewController];
    //register this class as a delegate so it will receive events defined in the delegate class
    [placeTypeViewController setDelegate:self];
    
    //pass the current filter back so we can highlight the current selection
    placeTypeViewController.placeType = placeType;
  }

  if ([segue.destinationViewController respondsToSelector:@selector(setPlace:)]) {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    Place *selectedPlace = [Place convertFromDictionary:[results objectAtIndex:path.row] withPlacemark:placemark];
    
    [segue.destinationViewController performSelector:@selector(setPlace:)
                                          withObject:selectedPlace];
  }
}

- (IBAction)unwindToSearchController:(UIStoryboardSegue *)segue {
  //  LocationSearchViewController *locationSearchViewController = [segue sourceViewController];
  ////  locationSearchViewController
  //  self.searching = locationSearchViewController.closeButtonClicked;
  //  [self reloadTableViewData];
}

@end