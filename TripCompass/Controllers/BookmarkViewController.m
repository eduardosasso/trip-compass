#import "BookmarkViewController.h"
#import "PlaceDataManager.h"

@implementation BookmarkViewController {
  NSMutableArray *cities;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.tableView registerNib:[UINib nibWithNibName:@"BookmarkCell" bundle:nil] forCellReuseIdentifier:@"BookmarkCell"];
}

-(void)viewWillAppear:(BOOL)animated {
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  cities = [NSMutableArray arrayWithArray:[PlaceDataManager findCities]];
  
  [self.tableView reloadData];
}

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
  
  NSDictionary *place = [cities objectAtIndex:indexPath.row];
  
  cell.placeLabel.text = [place valueForKey:@"city"];
  cell.detailLabel.text = [[place objectForKey:@"count"] stringValue];

  return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell"];
//  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
//  
//  return [cell calculateHeight:[place valueForKey:@"area"]];
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *place = [cities objectAtIndex:indexPath.row];
  
  [PlaceDataManager destroyByCity:[place valueForKey:@"city"]];
  
  [cities removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  [self performSegueWithIdentifier:@"BookmarkItemViewController" sender:self];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];
  NSDictionary *place = [cities objectAtIndex:path.row];
  
  [segue.destinationViewController performSelector:@selector(setCity:)
                                        withObject:[place valueForKey:@"city"]];
}

#pragma mark Undefined
- (NSString *)googleAnalyticsScreenName {
  return @"Bookmark";
}


@end
