#import "PlaceViewController.h"
#import "Place.h"
#import "PlaceModel.h"
#import "AppDelegate.h"
#import "API.h"
#import "CustomCell.h"

@interface PlaceViewController ()
@end

@implementation PlaceViewController {
  NSArray *searchFilters;
  AppDelegate *appDelegate;
  NSString *lat;
  NSString *lng;
  NSString *placeType;
  UIView *defaultTableHeaderView;
  API *api;

  NSMutableArray *results;
  NSArray *apiResults;
  
  NSInteger page;
}

#pragma mark Controller Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self resetTableViewData];

  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];
  
  //todo get the initial size dynamically from the constraints
  //self.tableView.estimatedRowHeight = self.tabBarController.topLayoutGuide.length;

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiResultsNotificationReceived:) name:@"apiResultsNotification" object:nil];
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//  self.managedObjectContext = [appDelegate managedObjectContext];
  
  self.tabBarController.delegate = self;
  defaultTableHeaderView = [self.tableView tableHeaderView];
  
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
//  [self.refreshControl endRefreshing];
//  self.tabBarController.navigationItem.title = @"Nearby Search";
//  self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

//- (void)viewDidAppear:(BOOL)animated {
//  [self requestUpdateTableViewData];
//}

#pragma mark API
- (void)apiResultsNotificationReceived:(NSNotification *)notification {
  apiResults = [[notification userInfo] valueForKey:@"results"];

  [self.refreshControl endRefreshing];
  [self.tableView reloadData];
}

- (void)resetTableViewData{
  page = 1;
  results = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)requestUpdateTableViewData{
  CLLocationCoordinate2D currentLocation = [(AppDelegate*)appDelegate currentLocation];
  api = [[API alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];

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

- (void)willPaginateTableView {
  results.count == 0 ? page=1 : page++;
  [self requestUpdateTableViewData];
}

#pragma mark Delegates

- (void)didSelectPlaceType:(NSString *)type {
  placeType = type;
  [self resetTableViewData];
  [self requestUpdateTableViewData];
}

#pragma mark UITableView

- (IBAction)pullToRefresh:(id)sender {
  [self resetTableViewData];
  [self requestUpdateTableViewData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (page > 1 && apiResults.count == 0) {
    return results.count;
  }
  
  [results addObjectsFromArray:apiResults];
  
  //+1 for the loading cell
  return results.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < results.count) {
    CustomCell *customCell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    
    Place *place = [self getPlace:indexPath.row];
    
    customCell.placeLabel.text = place.name;
    customCell.detailLabel.text = [place formattedDistanceTo:[(AppDelegate*)appDelegate currentLocation]];
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  //if the current cell is the loading one we should fetch next page
  if ([cell.reuseIdentifier isEqualToString:@"loadingCell"]) [self willPaginateTableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//  if ([cell.reuseIdentifier isEqual: @"FilterCell"]) {
//    [self.searchBar resignFirstResponder];
//    self.searching = NO;
//    self.searchBar.text = nil;
//    
////    NSString *source = @"create";
////    
////    if ([type isEqual: @"Popular"]) {
////      type = @"all";
////      source = @"explore";
////    }
//    
////    NSString *apiUrl = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&type=%@&page=1&lng=%@&lat=%@&per_page=20&source=%@&bypass=1", type, lng, lat, source];
//    
////    [self keywordSearch:apiUrl];
////    [self reloadTableViewData];
//    NSString *type = cell.textLabel.text;
//    
//    if ([type isEqualToString:@"Restaurants"]) [api getRestaurantsNearby];
//    if ([type isEqualToString:@"Attractions"]) [api getAttractionsNearby];
//    if ([type isEqualToString:@"Hotels"]) [api getHotelsNearby];
//  } else {
//    [self performSegueWithIdentifier:@"toMainView" sender:self];
//  }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return  UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//  if ([self.tableView isEditing]) {
//    Place *place = [self getPlace:indexPath.row];
//    
//    NSError *error;
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    [fetchRequest setEntity:entity];
//    
//    //  TODO should compare with id
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", place.name];
//    [fetchRequest setPredicate:predicate];
//    
//    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    
//    return [results count] == 0;
//  } else {
//    return YES;
//  }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  //  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
//  if (editingStyle == UITableViewCellEditingStyleDelete) {
//    //delete code here
//  }
//  else if (editingStyle == UITableViewCellEditingStyleInsert) {
//    Place *place = [self getPlace:indexPath.row];
//    
//    NSManagedObjectContext *context = [self managedObjectContext];
//    
//    PlaceModel *placeModel = [NSEntityDescription insertNewObjectForEntityForName:@"PlaceModel" inManagedObjectContext:context];
//    placeModel.name = place.name;
//    placeModel.lat = place.lat;
//    placeModel.lng = place.lng;
//    placeModel.area = place.area;
//    
//    NSError *error;
//    if (![context save:&error]) {
//      NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//    }
//    
//    [self.tableView reloadData];
//  }
//  
}

#pragma mark Search

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//  [self setEditing:NO animated:YES];
//  self.searching = YES;
//  [searchBar setShowsCancelButton:YES animated:YES];
//  [self.tableView reloadData];
//  return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
//  self.searching = NO;
//	[searchBar sizeToFit];
//  
//	[searchBar setShowsCancelButton:NO animated:YES];
//  
//  NSLog(@"searchBarShouldEndEditing");
//  
//	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//  [api searchPlacesNearby:searchText];
//  
//  self.searching = NO;
//  //  [self reloadTableViewData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//  [searchBar resignFirstResponder];
//  self.searching = NO;
//  searchBar.text = nil;
  
//  [api getPlacesNearby];
  //  [self reloadTableViewData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
  self.searchDisplayController.searchResultsTableView.hidden = YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
  //  [self.searchDisplayController.searchBar becomeFirstResponder];
  //  [self.searchDisplayController.searchBar setText:@"whole"];
  //  [self.view addSubview:self.searchDisplayController.searchResultsTableView];
  self.searchDisplayController.searchResultsTableView.hidden = YES;
}


#pragma mark Undefined
- (Place *)getPlace:(NSInteger)row {
  NSDictionary *result = [results objectAtIndex:row];
  
  id place_lat = [result valueForKeyPath:@"address.lat"];
  id place_lng = [result valueForKeyPath:@"address.lng"];
  
  Place *place = [[Place alloc] init];
  place.name = [result objectForKey:@"name"];
  place.address = [result valueForKeyPath:@"address.address"];
  place.lat = [NSNumber numberWithDouble:[place_lat doubleValue]];
  place.lng = [NSNumber numberWithDouble:[place_lng doubleValue]];
  place.area = [result objectForKey:@"travel_unit"];
  
  return place;
}

- (NSString *)googleAnalyticsScreenName {
  return @"Place";
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([[segue identifier] isEqualToString:@"placeType"]) {
    PlaceTypeViewController * placeTypeViewController = (PlaceTypeViewController *)[segue.destinationViewController topViewController];
    //register this class as a delegate so it will receive events defined in the delegate class
    [placeTypeViewController setDelegate:self];
    
    //pass the current filter back so we can highlight the current selection
    placeTypeViewController.placeType = placeType;
  }
  
  //  if([[segue identifier] isEqualToString:@"toMainView"]) {
  //    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
  //
  //    UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
  //    MainViewController *mainViewController = [[navigationController viewControllers] lastObject];
  //
  //    Place *place = [self getPlace:path.row];
  //    mainViewController.place = place;
  //  }
}

- (IBAction)unwindToSearchController:(UIStoryboardSegue *)segue {
  //  LocationSearchViewController *locationSearchViewController = [segue sourceViewController];
  ////  locationSearchViewController
  //  self.searching = locationSearchViewController.closeButtonClicked;
  //  [self reloadTableViewData];
}

@end