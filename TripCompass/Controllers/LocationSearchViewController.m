#import "LocationSearchViewController.h"
#import "API.h"

@implementation LocationSearchViewController {
  API *api;
  NSArray *results;
  NSTimer *searchTimer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  [self.tableView reloadData];
}

//- (void)apiResultsNotificationReceived:(NSNotification *)notification {
//  results = [[notification userInfo] valueForKey:@"results"];
//  
//  [self.refreshControl endRefreshing];
//  [self.tableView reloadData];
//}

#pragma mark Search Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  if (searchTimer) {
    [searchTimer invalidate];
    searchTimer = nil;
  }
  
  if ([searchString length] < 3) return NO;
  
  searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                               selector:@selector(searchTimerPopped:)
                                               userInfo:searchString
                                                repeats:FALSE];
  
  return YES;
}

-(void) searchTimerPopped:(NSTimer *)timer {
  NSString *searchString = (NSString*)[timer userInfo];

  [api searchLocation:searchString];
  [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//  [results removeAllObjects];
//  [self.tableView reloadData];
}

#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  //return results.count + 1;
  return results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  
//  if (indexPath.row == 0) {
//    cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
//  } else {
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    NSDictionary *region = [results objectAtIndex:indexPath.row];
    cell.textLabel.text = [region objectForKey:@"long_name"];
//  }
  
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


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
//  
//  if([[segue identifier] isEqualToString:@"NewLocation"]) {
//    Place *place = [self.places objectAtIndex:(indexPath.row-1)];
//    appDelegate.selectedLocation = place;
//  } else {
//    appDelegate.selectedLocation = NULL;
//  }
//  
//}

- (NSString *)googleAnalyticsScreenName {
  return @"Location Search";
}

@end
