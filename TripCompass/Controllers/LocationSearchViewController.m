#import "LocationSearchViewController.h"
#import "AppDelegate.h"
//#import "SearchViewController.h"

@interface LocationSearchViewController ()

@property (nonatomic) NSMutableArray *results;
@property (retain, nonatomic) NSMutableArray *places;

@end

@implementation LocationSearchViewController {
  AppDelegate *appDelegate;
}

- (void)viewDidAppear:(BOOL)animated {
  [self.searchBar becomeFirstResponder];
}

- (NSString *)googleAnalyticsScreenName {
  return @"Location Search";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.places = [[NSMutableArray alloc] init];
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
  self.navigationItem.rightBarButtonItem = nil;
  self.navigationItem.leftBarButtonItem = self.closeButton;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  NSString *encodedSearchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  
//  NSString *lat = [NSString stringWithFormat:@"%.5f", appDelegate.currentLocation.longitude];
//  NSString *lon = [NSString stringWithFormat:@"%.5f", appDelegate.currentLocation.latitude];
  
//  NSString *apiUrl = [NSString stringWithFormat:@"http://api.gogobot.com/api/v3/places/region_search.json?_v=2.1&lng=%@&lat=%@&term=%@&bypass=1", lon , lat, encodedSearchString];
  
//  [self keywordSearch:apiUrl];

  [self.tableView reloadData];

  return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self.results removeAllObjects];
  [self.tableView reloadData];
}

- (void)keywordSearch:(NSString *)apiUrl {
//  NSURL *url = [NSURL URLWithString:apiUrl];
//  NSURLRequest *request = [NSURLRequest requestWithURL:url];
//  
//  [self.places removeAllObjects];
//  
//  AFJSONRequestOperation *operation = [AFJSONRequestOperation
//                                       JSONRequestOperationWithRequest:request
//                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
//                                         self.results = [[json objectForKey:@"results"] mutableCopy];
//                                         [self.tableView reloadData];
//                                       } failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON){
//                                         NSLog(@"Failed: %@",[error localizedDescription]);
//                                       }];
//  
//  [operation start];
}

#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.results.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  
  if (indexPath.row == 0) {
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
  } else {
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    NSDictionary *result = [[self.results objectAtIndex:(indexPath.row -1)] mutableCopy];
    
    Place *place = [[Place alloc] init];
    place.name = [result objectForKey:@"name"];
    place.lat = [NSNumber numberWithDouble:[[result valueForKeyPath:@"address.lat"] doubleValue]];
    place.lng = [NSNumber numberWithDouble:[[result valueForKeyPath:@"address.lng"] doubleValue]];
    
    [self.places addObject:place];
    cell.textLabel.text = place.name;
    
    if ([result objectForKey:@"travel_unit"] != [NSNull null]) {
      cell.detailTextLabel.text = [result objectForKey:@"travel_unit"];
    }
    
  }
  
  return cell;
}
- (IBAction)closeButtonClick:(id)sender {
  self.closeButtonClicked = YES;
  [self performSegueWithIdentifier:@"unwindToSearchController" sender:self];

//  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  //  NSIndexPath *indexPathx = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
  
  if ([cell.reuseIdentifier isEqual: @"DefaultCell"]) {
    Place *place = [self.places objectAtIndex:(indexPath.row-1)];
//    appDelegate.selectedLocation = place;
  }
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


@end
